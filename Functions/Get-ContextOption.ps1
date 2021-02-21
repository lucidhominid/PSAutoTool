[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Extension
)
$Extension = $Extension -replace '^\.*','.'
Get-ItemProperty HKLM:\SOFTWARE\Classes\SystemFileAssociations\$Extension\Shell\*






$DownloadUri = [Regex]::Matches(
        (Invoke-RestMethod "https://github.com/git-for-windows/git/releases"),
        '(?<=href\=").+/Git-(\d+)(\.\d+)\.(\d+)-64-bit\.[xe]{3}'
    ) |
	Sort-Object {
		[double](($_.Groups[1..3].Value.TrimStart('0') -join '')+'0')
	} -Descending |
	Select-Object -ExpandProperty Value -First 1
$FileName = $DownloadUri -split('/')|
    Select-Object -Last 1
Write-Verbose "Downloading $FileName from https://github.com."
Invoke-RestMethod -Uri https://github.com/$DownloadUri -OutFile $env:TEMP\$FileName
Write-Verbose "Installing $FileName."
&"$env:TEMP\$FileName" /VerySilent
(Resolve-Path 'C:\Program Files*\git',"C:\Users\$env:Username\AppData\L*\Pr*\Git\cmd")[0].Path

