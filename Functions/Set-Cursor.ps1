[CmdletBinding()]
param (
    [Parameter(
        ValueFromPipeLine,
        Position = 0
    )][ArgumentCompleter({
        param($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
            'ScreenCenter',
            'ScreenBottomLeft',
            'ScreenBottomRight',
            'ScreenTopLeft',
            'ScreenTopRight',
            'WindowCenter',
            'WindowBottomLeft',
            'WindowBottomRight',
            'WindowTopLeft',
            'WindowTopRight'|
                Where-Object -like "*$wordToComplete*"
    })][Object[]]
    $Position,

    [Parameter()]
    [ArgumentCompleter({
        param($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
        [PSAutoTool.Cursor].DeclaredMethods|
            Where-Object {
                $_.IsPublic `
                -and `
                $_.Name -notmatch "^[GgSs]et" `
                -and `
                $_.Name -like "$wordToComplete*"
            }|
            Foreach-Object{
                [System.Management.Automation.CompletionResult]::new(
                    $_.Name,
                    $_.Name, 
                    'ParameterValue',
                    (
                        (
                            $_|Select-Object Name, Module, *Type* |
                                Format-List |
                                Out-String
                        ) -replace '\n\n+',"`n"
                    )
                )
            }
    })][String]
    $Action,
    [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'RecordedState'
    )]
    $Buttons,

    [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'RecordedState'
    )][Int]$Delay = 5,

    [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'RecordedState'
    )][Switch]
    $ClearOnEnd,

    [Parameter(
        ValueFromPipelineByPropertyName
    )][Switch]
    $Relative
)
begin{
    $Methods = [PSAutoTool.Cursor].DeclaredMethods.Name|
        ForEach-Object{
            @{$_.toLower() = $_}
        } 

        $PerformAction = {
            $Method     = $Methods.($Args[0])
            $MethodArgs = $Args[1..2] -join ','
            Write-Verbose ($Args -join ' ').replace($Args[0],$Method)
            Invoke-Expression "[PSAutoTool.Cursor]::$Method($MethodArgs)"
            Start-Sleep -milliseconds 5
        }

        if($ClearOnEnd){
            Write-Verbose 'Clearing mouse button state.'
            'LeftUp'
            'RightUp' |
                ForEach-Object {
                    &$PerformAction $_
                }
        }
}
process{
    if($Position){
        if($Relative){
            $Current = &$PerformAction GetPosition
        }else{
            $Current = $null
        }
        $ScreenBounds = Get-SystemInformation 
        $WindowBounds = [PSAutoTool.Window]::GetWindowPostion([PSAutoTool.Window]::GetForegroundWindow())
        $Position2 = Switch($Position){
            'ScreenCenter'{
                [Int](( $ScreenBounds.Right -  $ScreenBounds.Left)/2 +  $ScreenBounds.Left),
                [Int](( $ScreenBounds.Bottom -  $ScreenBounds.Top)/2 +  $ScreenBounds.Top);Break
            }
            'ScreenCenterTop'{
                [Int](( $ScreenBounds.Right -  $ScreenBounds.Left)/2 +  $ScreenBounds.Left),
                $ScreenBounds.Top;Break
            }
            'ScreenBottomLeft'{
                $ScreenBounds.Left,
                $ScreenBounds.Bottom;Break
            }
            'ScreenBottomRight'{
                $ScreenBounds.Right,
                $ScreenBounds.Bottom;Break
            }
            'ScreenTopLeft'{
                $ScreenBounds.Left,
                $ScreenBounds.Top;Break
            }
            'ScreenTopRight'{
                $ScreenBounds.Top
                $ScreenBounds.Right;Break
            }
            'WindowCenter'{
                [Int](( $WindowBounds.Right -  $WindowBounds.Left)/2 +  $WindowBounds.Left),
                [Int](( $WindowBounds.Bottom -  $WindowBounds.Top)/2 +  $WindowBounds.Top);Break
            }
            'WindowCenterTop'{
                [Int](( $WindowBounds.Right -  $WindowBounds.Left)/2 +  $WindowBounds.Left),
                $WindowBounds.Top;Break
            }
            'WindowBottomLeft'{
                $WindowBounds.Left,
                $WindowBounds.Bottom;Break
            }
            'WindowBottomRight' {
                $WindowBounds.Right,
                $WindowBounds.Bottom;Break
            }
            'WindowTopLeft' {
                $WindowBounds.Left,
                $WindowBounds.Top;Break
            }
            'WindowTopRight' {
                $WindowBounds.Top
                $WindowBounds.Right;Break
            }
        }

        if($Position2){
            $Position = $Position2
        }
        if($Position[0] -is [int]){
            Write-Verbose 'Converting array to point.'
            $Position = @{
                x = $Position[0]
                y = $Position[1]
            }
        }
        &$PerformACtion SetPosition ([Int]$Current.x + [Int]$Position.x) ([Int]$Current.y + [Int]$Position.y)
            
        }
    if($Action){
        &$PerformAction $Action
        Start-Sleep -milliseconds $Delay
    }
    if($Buttons){
        Start-Sleep -milliseconds $Delay
        $NewButtons     = $Buttons -split ', '

        'Left','Right'|
            ForEach-Object{
                if(
                    $NewButtons  -inotcontains $_
                ){
                    &$PerformAction $_`Up
                }elseif(
                    $NewButtons  -icontains $_ -and
                    $LastButtons -inotcontains $_
                ){
                    &$PerformAction $_`Down
                }
            }
        $LastButtons = $NewButtons
        
    }
}
end{
    if($ClearOnEnd){
        Write-Verbose 'Clearing mouse button state.'
        'LeftUp'
        'RightUp' |
            ForEach-Object {
                &$PerformAction $_
            }
    }
}