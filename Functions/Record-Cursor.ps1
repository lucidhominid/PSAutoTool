param(
    $Duration = 10,
    $Delay = 5,
    [Switch]
    $Relative
)
Write-Host "Cursor recording starts in $Delay seconds.."
1..$Delay |
    ForEach-Object{
        Start-Sleep 1
        $Delay--
        Write-Host $Delay
    }
$LastCursor = Get-Cursor
1..($Duration*100)|
    ForEach-Object {
        $Current = $_/100
        if($Current -is [int]){
            Write-Host "Recording. $($Duration - $Current) seconds left..."
        }
        $CurrentCursor = Get-Cursor
        if($Relative){
            [PSCustomObject]@{
                X = $CurrentCursor.X-$LastCursor.X
                Y = $CurrentCursor.Y-$LastCursor.Y
                Buttons = $CurrentCursor.Buttons
                Relative = $true
            }
            $LastCursor = $CurrentCursor
        }else{
            $CurrentCursor
        }
        Start-Sleep -Milliseconds 10
    }
