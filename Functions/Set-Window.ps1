[CmdletBinding()]
param (
    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName,
        ValueFromPipeLine
    )][Int]
    $Handle,

    [Parameter()]
    [ArgumentCompleter({
        param($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
        [PSAutoTool.Window].DeclaredMethods|
            Where-Object {
                $_.IsPublic -and
                $_.Name -notmatch "^Get" -and 
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
    })]
    [String[]]
    $Action
)
process{
    $Action |
        ForEach-Object{
            Invoke-Expression "[void][PSAutoTool.Window]::$_($Handle)"
        }
}