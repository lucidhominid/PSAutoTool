[CmdletBinding(DefaultParameterSetName = 'Name')]
param (
    [Parameter(
        ParameterSetName = 'Name',
        ValueFromPipelineByPropertyName
    )][String]$Name = "*",
    [Parameter(
        ParameterSetName = 'Id',   
        ValueFromPipelineByPropertyName
    )][Int]$Id = $Pid,
    [Parameter(        
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
    )][String]
    $Title = "*"
)
Process{

    $Parameters = @{
        $PSCmdlet.ParameterSetName = Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly
    }

    Foreach($Process in Get-Process @Parameters | Where-Object MainWindowHandle -notlike "0"){
        [Object[]]$ChildWindows  = [PSAutoTool.Window]::GetChildWindows($Process.MainWindowHandle)
        $ChildWindows += $Process.MainWindowHandle
            For($i=0;$i -lt $ChildWindows.Count;$i++){
                [PSCustomObject]@{  
                    Handle       = $ChildWindows[$i] 
                    Title        = [PSAutoTool.Window]::GetTitle($ChildWindows[$i])
                    isMainWindow = $Process.MainWindowHandle -eq $ChildWindows[$i]
                    ProcessName  = $Process.Name
                    ProcessId    = $Process.Id
                    Position     = [PSAutoTool.Window]::GetWindowPostion($ChildWindows[$i])
                }|
                    Where-Object Title -like $Title
                $ChildWindows   += [PSAutoTool.Window]::GetChildWindows($ChildWindows[$i])
            }
    }
}