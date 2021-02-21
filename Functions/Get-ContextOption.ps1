[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Extension
)
$Extension = $Extension -replace '^\.*','.'
Get-ItemProperty HKLM:\SOFTWARE\Classes\SystemFileAssociations\$Extension\Shell\*

