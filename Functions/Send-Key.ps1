[CmdletBinding(
    DefaultParameterSetName = 'String'
)]
param (
    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'Key'
    )][ArgumentCompleter({
        param(
            $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters
        )
        (
            [Scriptblock]::Create(
                (Get-Command 'Send-Key').Definition
            ).Ast.beginblock.statements|
                Where-Object Left -like '$KeyCodes'
        ).Right.Expression.KeyValuePairs|
            ForEach-Object{
                [System.Management.Automation.CompletionResult]::new(
                    $_.Item1.value,
                    $_.Item1.value, 
                    'ParameterValue',
                    $_.Item2.extent.text.trim("`n")
                )
            }
    })][String]
    $Key,

    [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'Key'
    )][Parameter(
        ParameterSetName = 'String'
    )][ValidateSet(
        'Alt',
        'Control',
        'Shift'
    )][String]
    $Modifier,

    [Parameter(
        Mandatory,
        ValueFromPipeline,
        ParameterSetName = "KeyStroke"
    )][PSAutoTool.Keyboard.KeyStroke]
    $KeyStroke,

    [Parameter(
        Mandatory,
        ValueFromPipeline,
        ParameterSetName = "String"
    )][Parameter(
        Mandatory,
        ValueFromPipeline,
        ParameterSetName = "StringRaw"
    )][String]
    $String,

    [Parameter(
        Mandatory,
        ParameterSetName = "StringRaw")]
    [Switch]
    $Raw
)
begin{
$KeyCodes = @{
    Backspace  ="{BACKSPACE}"
    Capslock   ="{CAPSLOCK}"
    Delete     ="{DELETE}"
    Down       ="{DOWN}"
    End        ="{END}"
    Enter      ="{ENTER}"
    Esc        ="{ESC}"
    Help       ="{HELP}"
    Home       ="{HOME}"
    Insert     ="{INSERT}"
    Left       ="{LEFT}"
    Num        ="{NUMLOCK}"
    Pagedown   ="{PGDN}"
    Pageup     ="{PGUP}"
    Print      ="{PRTSC}"
    Right      ="{RIGHT}"
    Scrolllock ="{SCROLLLOCK}"
    Tab        ="{TAB}"
    Up         ="{UP}"
    F1         ="{F1}"
    F2         ="{F2}"
    F3         ="{F3}"
    F4         ="{F4}"
    F5         ="{F5}"
    F6         ="{F6}"
    F7         ="{F7}"
    F8         ="{F8}"
    F9         ="{F9}"
    F10        ="{F10}"
    F11        ="{F11}"
    F12        ="{F12}"
    F13        ="{F13}"
    F14        ="{F14}"
    F15        ="{F15}"
    F16        ="{F16}"
    Add        ="{ADD}"
    Subtract   ="{SUBTRACT}"
    Multiply   ="{MULTIPLY}"
    Divide     ="{DIVIDE}"
    Alt        ="%"
    Control    ="^"
    Shift      ="+"
}
    $KeysType = [PSAutoTool.Keyboard.Keys]
}
process{
    Switch($PsCmdlet.ParameterSetName){
        String {
            $SendString = $String.ToCharArray() |
                ForEach-Object{
                    $KeyCodes.$Modifier + "{$_}"
                }
            $KeysType::Send((
                $SendString -join ''
            ))
        }
    
        StringRaw {
            $KeysType::Send($String)
        }
    
        Key {
            [PSAutoTool.Keyboard.KeyStroke]::New(
                (($Modifier | ForEach-Object {
                    $KeyCodes.$_
                })-join''),
                (($Key | ForEach-Object {
                    $KeyCodes.$_
                })-join'')
            ).Send()
        }
    
        KeyStroke {
            $KeyStroke.Send()
        }
    }
    
}