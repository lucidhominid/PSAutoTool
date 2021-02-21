[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Path = (Get-Location),
    [Parameter()]
    [String]
    $TargetPath,
    [Parameter()]
    $ArgumentList,
    [Parameter()]
    [ValidateSet('Normal','Minimized','Maximized','Hidden')]
    [String]$WindowStyle = 'Normal',
    [Parameter()]
    $Hotkey,
    [Parameter()]
    $RelativePath,
    [Parameter()]
    [String]
    $WorkingDirectory
)
$Shell    = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut(
    ($Path -replace '(?<!\.lnk)$','.lnk')
)
$Shortcut.Arguments        = $ArgumentList
$Shortcut.Hotkey           = $Hotkey
$Shortcut.RelativePath     = $RelativePath
$Shortcut.TargetPath       = $TargetPath
$Shortcut.WorkingDirectory = $WorkingDirectory
$Shortcut.WindowStyle      = Switch($WindowStyle)
{
    'Minimized' {0;Break}
    'Maximized' {2;Break}
    'Hidden'    {3;Break}
    Default     {1}
}
if($Save)
{
    $Shortcut.Save()
}
else 
{
    $Shortcut
}