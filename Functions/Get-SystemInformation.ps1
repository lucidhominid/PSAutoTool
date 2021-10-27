[CmdletBinding()]
param (
    [Parameter(
        Position=0,
        ValueFromPipeline
    )][ArgumentCompleter({
        param($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
        [System.Windows.Forms.SystemInformation].DeclaredProperties |
            Where-Object {
                $_.Name -like "*$wordToComplete*"
            }|
            Foreach-Object{
                [System.Management.Automation.CompletionResult]::new(
                    [String]$_.Name,
                    [String]$_.Name, 
                    'ParameterValue',
                    $(
                        (
                            $_ | Format-List |
                                Out-String
                        ) -replace '\n\n+',"`n"
                    )
                )
            }
    })][String]
    $Name = "*"
)
begin{
    $Selections = @()
}
process{
    $Selections += [System.Windows.Forms.SystemInformation].DeclaredProperties |
        Where-Object Name -like $Name
}
end{
    if($Selections.Count -eq 1){
        [System.Windows.Forms.SystemInformation]::($Selections.Name)
    }else{
        $OutObject = [PScustomObject]@{}
        $Selections.Name |
            Sort-Object |
            Select-Object -Unique |
            ForEach-Object{
                $OutObject|
                    Add-Member -MemberType NoteProperty -Name $_ -Value (
                        [System.Windows.Forms.SystemInformation]::$_
                    )
            }
        $OutObject 
    }
}