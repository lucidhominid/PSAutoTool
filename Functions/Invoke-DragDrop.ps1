[CmdletBinding()]
param (
    [Parameter(
        Mandatory
    )]
    $Start,
    [Parameter(
        Mandatory
    )]
    $End,
    [Parameter()]
    [Int]
    $Duration = 50,
    [Parameter()]
    [Int]
    $Jitter = 1
) 
If($Start -isnot [System.Drawing.Point]){
    $Start = [System.Drawing.Point]::new($Start[0],$Start[1])
}
If($End -isnot [System.Drawing.Point]){
    $End = [System.Drawing.Point]::new($End[0],$End[1])
}
$Incrementer = [Int]($duration/2)
Set-Cursor -Position $Start
Set-Cursor -Button LeftUp
Start-Sleep 1
Set-Cursor -Button LeftDown
while (
    ([Math]::Abs($Current.x - $end.x) -ge (10 + $Jitter)) -or
    ([Math]::Abs($Current.y - $end.y) -ge (10 + $Jitter))
){
    $Current = Get-Cursor
    Set-Cursor -Position (
        [int](($end.x - $Current.x )/$Incrementer)+ (1..$jitter|Get-Random) + $Current.x
    ),(
        [int](($end.y - $Current.Y )/$Incrementer)+ (1..$jitter|Get-Random) + $Current.y
    )
    Write-Verbose ($Current|Format-List|Out-String)
    Start-Sleep -milliseconds $Incrementer
    if($Incrementer -gt 1){
        $Incrementer--
    }
    
}
Set-Cursor -Position $End
Set-Cursor -Button LeftUp