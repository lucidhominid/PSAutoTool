[CmdletBinding()]
param (
    [Parameter(Mandatory,ValueFromPipeline)]
    [String]
    $Key
)
process{
    [PSAutoTool.Keyboard]::SendKeys($Key)
}