[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline)]
    [String]
    $InputObject
)
process
{
    [System.BitConverter]::ToString(
        [System.Security.Cryptography.MD5CryptoServiceProvider]::new().ComputeHash(
            [System.Text.UTF8Encoding]::UTF8.GetBytes(
                $(
                    Switch($InputObject)
                    {
                        {$_ -is [String]} {
                            $_
                        }
                        {$_ -is [System.IO.FileInfo]} {
                            $_|Get-Content|Out-String
                        }
                    }
                )
            )
        )
    ).tolower() -replace '-'
}



"C:\Program Files (x86)\Advanced IP Scanner\advanced_ip_scanner.exe" |
    Get-Item|
    Foreach-Object{
        $Shortcut = $WScriptShell.CreateShortcut(
           
        )
    
    }

C:\Windows\powershell.exe -notexit {$WScriptShell = (New-Object -ComObject WScript.Shell).CreateShortcut( ($Args[0].split('\') -replace '\.[^\.]+$','.lnk')) |%{$_.TargetPath=$Args[0];$_.Save()}} "%1"