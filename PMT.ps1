Add-Type -AssemblyName PresentationFramework
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   Height="400" Width ="600"
   Title="Printer" Topmost="True">
    <Grid>
        <TabControl Name="tabControl" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
            <TabItem Header="Verfügbare Drucker">
                <Grid Background="#FFE5E5E5">
                    <TextBox Name="textBox" HorizontalAlignment="Left" Height="23" Margin="10,10,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="194"/>
                    <ListView Name="lv1" HorizontalAlignment="Stretch" Margin="10,40,10,40" VerticalAlignment="Stretch">
                        <ListView.ContextMenu>
                            <ContextMenu>
                                <MenuItem Name ="Verbinden" Header="Verbinden"/>
                                <MenuItem Name ="Eigenschaften" Header="Eigenschaften"/>
                            </ContextMenu>
                        </ListView.ContextMenu>
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding 'Name'}" Width="120"/>
                                <GridViewColumn Header="Beschreibung" DisplayMemberBinding ="{Binding 'Beschreibung'}" Width="120"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                    <Button Name="button" Content="Button" HorizontalAlignment="Right" Margin="0,0,10,10" VerticalAlignment="Bottom" Width="75"/>
                </Grid>
            </TabItem>
            <TabItem Header="Meine Drucker">
                <Grid Background="#FFE5E5E5">
                    <ListView Name="lv2" HorizontalAlignment="Stretch" Margin="10,10,10,40" VerticalAlignment="Stretch">
                        <ListView.ContextMenu>
                            <ContextMenu>
                                <MenuItem Name ="MyTrennen" Header="Trennen"/>
                                <MenuItem Name ="MyEigenschaften" Header="Eigenschaften"/>
                            </ContextMenu>
                        </ListView.ContextMenu>
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding 'Name'}" Width="120"/>
                                <GridViewColumn Header="Beschreibung" DisplayMemberBinding ="{Binding 'Beschreibung'}" Width="120"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                    <Button Name="button2" Content="Button" HorizontalAlignment="Right" Margin="0,0,10,10" VerticalAlignment="Bottom" Width="75"/>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
'@
function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory)]
    [string]
    $XAML,
    [string[]]
    $NamedElement=$null,
    [switch]
    $PassThru
  )
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  foreach($Name in $NamedElement){
    $result | Add-Member NoteProperty -Name $Name -Value $result.FindName($Name) -Force
  }
  if ($PassThru){
    $result
  }
  else{
    $null = $window.Dispatcher.InvokeAsync{
      $result = $window.ShowDialog()
      Set-Variable -Name result -Value $result -Scope 1
    }.Wait()
    $result
  }
}
function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory)]
    [Windows.Window]
    $Window
  )
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}

$window = Convert-XAMLtoWindow -XAML $xaml -NamedElement 'button', 'button2', 'Eigenschaften', 'lv1', 'lv2', 'MyEigenschaften', 'MyTrennen', 'tabControl', 'textBox', 'Trennen', 'Verbinden' -PassThru

function Get-MyPrinter
{
  Get-Printer | select Name | ForEach-Object {$window.lv2.addchild($_)}
}


function Set-WindowPosition
{
  $window.Left = $([System.Windows.SystemParameters]::WorkArea.Width-$window.Width)
  $window.Top = $([System.Windows.SystemParameters]::WorkArea.Height-$window.Height)
}

$Window.Add_ContentRendered({    
  Set-WindowPosition
  Get-MyPrinter
})


$result = Show-WPFWindow -Window $window
