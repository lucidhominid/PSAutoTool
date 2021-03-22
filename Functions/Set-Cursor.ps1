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
    $Button,

    [Switch]
    $Relative
)
process{
    if($Position){
        if($Relative){
            $Current = [PSAutoTool.Cursor]::GetPosition()
        }else{
            $Current = $null
        }
        [PSAutoTool.Cursor]::SetPosition(
            (
                $Current.x+ (
                $Position.x,[Int]$Position[0] |
                    Where-Object {$_ -is [int]}|
                    Select-Object -First 1
            )),
            (
                $Current.y+ [Int](
                $Position.y,[Int]$Position[1] |
                    Where-Object {$_ -is [int]}|
                    Select-Object -First 1
            ))
        )

        Start-Sleep -milliseconds 50
    }
    if($Button){
        Invoke-Expression "[PSAutoTool.Cursor]::$Button()"
        Start-Sleep -milliseconds 50
    }
}