[CmdletBinding()]
param (
    [Parameter(
        ValueFromPipeLineByPropertyName
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
                            $_|Select-Object Name, Module, *Type*|
                                Format-List|Out-String
                        ) -replace '\n\n+',"`n"
                    )
                )
            }
    })][String]
    $Button
)
process{
    if($Position){
        [PSAutoTool.Cursor]::SetPosition(
            (
                $Position.x,$Position[0] |
                    Where-Object {$_ -is [int]}|
                    Select-Object -First 1
            ),(
                $Position.y,$Position[1] |
                    Where-Object {$_ -is [int]}|
                    Select-Object -First 1
            )

        )
        Start-Sleep -milliseconds 50
    }
    if($Button){
        Invoke-Expression "[PSAutoTool.Cursor]::$Button()"
        Start-Sleep -milliseconds 50
    }
}