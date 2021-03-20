[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [String]
    $Version = "*.*.*",

    [Parameter(Position = 1)]
    [ValidateSet(
        '32','64'
    )][String]
    $Bitness = '64',
    
    [Parameter(Position = 2)]
    [ValidateScript({
        try{
            Invoke-RestMethod -Uri "$_"
        }catch{
            Throw $_.Exception
        }
    })][String]
    $Uri = 'https://github.com/git-for-windows/git/releases'
)
$ErrorActionPreference = 'Stop'
$DownloadUri = [Regex]::matches($Uri,'https{0,1}://[^/]+').Value + (
    [Regex]::Matches(
        (Invoke-RestMethod $Uri),
        "(?<=href\=`").+/Git-(\d+)(\.\d+)\.(\d+)-$Bitness-bit\.exe"
    ) |
        Sort-Object {
            [double](($_.Groups[1..3].Value.TrimStart('0') -join '')+'0')
        } -Descending |
        Where-Object {
            [Regex]::Match($_.Value,'Git-(\d+\.\d+\.\d+)-').groups[1] -Like $Version
        }|
        Select-Object -ExpandProperty Value -First 1
)
if(!($DownloadUri -like "*.exe")){
    $Exception =  "Git $Version could not be found at $Uri." -replace '\*\.\*\.\*' -replace '\s\s+',' '
    Write-Error -Message $Exception -Category ObjectNotFound -CategoryActivity "Install-Git" -CategoryReason 'Version not found.' -TargetObject $Version
    break
}

$FileName = $DownloadUri -split('/')|
    Select-Object -Last 1

if(Test-Path $env:TEMP\$FileName){
    Write-Verbose "Installer already present."
    if(
        [Regex]::Match($FileName,'Git-(\d+\.\d+\.\d+)-').groups[1] `
        -like `
        [Regex]::Match((get-command git.ex*).Version,'(\d+\.\d+\.\d+)').groups[1]
    ){
        Write-Host 'The specified version is already installed.'
        break
    }
}else {
    Write-Verbose "Downloading $FileName from https://github.com."
    Invoke-RestMethod -Uri $DownloadUri -OutFile $env:TEMP\$FileName
}

Write-Verbose "Installing $FileName."
Start-Process -Wait -FilePath "$env:TEMP\$FileName" /VerySilent
$Path = (Resolve-Path 'C:\Program Files*\Git',"C:\Users\$env:Username\AppData\L*\Pr*\Git\").Path
if($Path){
    Write-Host "Installed Git $Version to $Path."
}else{
    throw "Failed to install Git $Version."
}