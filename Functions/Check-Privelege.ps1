<#
    .SYNOPSIS
    This function checks which Security.Principal.WindowsBuiltInRole the current session is in by checking
    each one. It always checks Administrator first and User last.
    
    There are three parameter sets; 
        None    : Returns first matching role name.
        All     : Returns all matching role names.
        IsAdmin : Returns boolean from whether current session has Administrator priveleges.
    
    This information can be useful in a veriety of sitautons, especially when running scripts that require 
    certain priveleges.

    .DESCRIPTION
    Checks current session's privelege level.

    .PARAMETER -All
    [Switch]
    Gets all roles to which the current session is priveleged.

    .PARAMETER -IsAdmin
    [Switch]
    Checks only if the current session has Administrator Priveleges and returns the appropriate boolean.

    .OUTPUTS
    String
    String[]
    Bool

    .EXAMPLE 
    PS C:\WINDOWS\system32> Check-Privelege
    Administrator

    .EXAMPLE 
    PS C:\WINDOWS\system32> Check-Privelege -All
    Administrator
    User

    .EXAMPLE 
    PS C:\WINDOWS\system32> Check-Privelege -IsAdmin
    True
#>
[CmdletBinding(DefaultParameterSetName = 'None')]
param (
    # Display all results instead of just the first one.
    [Parameter(
        ParameterSetName = 'All',
        Position=0
    )][Switch]
    $All = $false,
    # Return true if current session has Administrator priveledges.
    [Parameter(
        ParameterSetName = 'IsAdmin',
        Position = 0
    )][Switch]
    $IsAdmin = $false
)
# Get all possible WindowsBuiltInRole names
$Privelege = [Security.Principal.WindowsBuiltInRole].DeclaredFields|
    Where-Object IsLiteral -eq $true |             
    Select-Object -ExpandProperty Name |
    Sort-Object {
        #Ensure that first to pass through is Administrator and the last is User
        $_ -replace '^Admin','11' -replace '^User','zz' 
    }|
    Where-Object{
        # Filter out ones that the current session is not in. This is the core of this function.
        [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::$_
        )
    }|
    Select-Object -First $(
        # Return all results if the All parameter was specified, otherwise return only the first one.
        If($All -eq $true){
            [Security.Principal.WindowsBuiltInRole].DeclaredFields.Count
        }else{
            1
        }
    )
    # Return boolean from whether current session has Administrator priveleges.
    if($IsAdmin -eq $true){
        $Privelege -contains 'Administrator'
    }else {
        $Privelege
    }
