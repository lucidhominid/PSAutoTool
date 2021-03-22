[PSAutoTool.Cursor]::GetPosition()|
    Select-Object X, Y|
    Add-Member -MemberType NoteProperty -Name Buttons -PassThru -Value (
        [PSAutoTool.Cursor]::GetButtons()
    )