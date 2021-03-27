[CmdletBinding()]
param (
    [Parameter(
        ValueFromPipeLine
    )][Object[]]
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
    )][Switch]
    $ClearOnEnd,

    [Parameter(
        ValueFromPipelineByPropertyName
    )][Switch]
    $Relative
)
begin{
    if($ClearOnEnd){
        [PSAutoTool.Cursor]::LeftUp()
        [PSAutoTool.Cursor]::RightUp()
    }
}
process{
    if($Position){
        if($Relative){
            $Current = [PSAutoTool.Cursor]::GetPosition()
        }else{
            $Current = $null
        }
        if($Position[0] -is [int]){
            $Position = @{
                x = $Position[0]
                y = $Position[1]
            }
        }
        [PSAutoTool.Cursor]::SetPosition(
            ([Int]$Current.x + [Int]$Position.x),
            ([Int]$Current.y + [Int]$Position.y)
        )

        Start-Sleep -milliseconds 5
    }
    if($Action){
        Invoke-Expression "[PSAutoTool.Cursor]::$Action()"
        Start-Sleep -milliseconds 50
    }
    if($Buttons){
        Start-Sleep -milliseconds 5
        $NewButtons     = $Buttons -split ', '
        'Left','Right'|
            ForEach-Object{
                if(
                    $NewButtons     -inotcontains $_
                ){
                    Invoke-Expression "[PSAutoTool.Cursor]::$_`Up()"
                }elseif(
                    $NewButtons     -icontains $_ -and
                    $LastButtons -inotcontains $_
                ){
                    Invoke-Expression "[PSAutoTool.Cursor]::$_`Down()"
                }
            }
        $LastButtons = $NewButtons
        
    }
}
end{
    if($ClearOnEnd){
        [PSAutoTool.Cursor]::LeftUp()
        [PSAutoTool.Cursor]::RightUp()
    }
}