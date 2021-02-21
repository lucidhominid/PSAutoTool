[CmdletBinding(DefaultParameterSetName = 'Id')]
param (
    [Parameter(
        ParameterSetName = 'Id',   
        ValueFromPipelineByPropertyName
    )][Int]$Id = $Pid,
    [Parameter(
        Mandatory,
        ParameterSetName = 'Name',
        ValueFromPipelineByPropertyName
    )][String]$Name
)
Process
{
    $Parameters = @{$PSCmdlet.ParameterSetName = Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly}
    Foreach($Process in Get-Process @Parameters|Where-Object MainWindowHandle -notlike "0")
    {
        [Object[]]$ChildWindows  = [PSAutoTool.Window]::GetChildWindows($Process.MainWindowHandle)
        $ChildWindows += $Process.MainWindowHandle
            For($i=0;$i -lt $ChildWindows.Count;$i++)
            {
                [PSCustomObject]@{  
                    Handle       = $ChildWindows[$i] 
                    Title        = [PSAutoTool.Window]::GetWindowTitle($ChildWindows[$i])
                    isMainWindow = $Process.MainWindowHandle -eq $ChildWindows[$i]
                    ProcessName  = $Process.Name
                    ProcessId    = $Process.Id
                }
                $ChildWindows   += [PSAutoTool.Window]::GetChildWindows($ChildWindows[$i])
            }
    }
}