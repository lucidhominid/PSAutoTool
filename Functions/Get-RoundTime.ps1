[CmdletBinding()]
param (
    [Parameter()]
    [Int]
    $Minutes = 15,
    [Parameter()]
    [datetime]
    $Time = (Get-Date)
)
[datetime][long]([long]($Time.Ticks/(6e8*$Minutes))*(6e8*$Minutes))