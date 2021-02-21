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