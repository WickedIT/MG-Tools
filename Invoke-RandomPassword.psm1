<#
Random password generator.
############################################################################
#>

function Invoke-RandomPassword {
    <#
    .SYNOPSIS
    Calls random Secure String password of 72 normal characters at any length noted by the length parameter.
    
    .DESCRIPTION
    Injects 72 characters to the Get-Random CMDlet to produce a string, then converts the string to a secure string. Once converted, the Password is displayed on the host and copied to the clipboard.
    
    .PARAMETER Length
    Use an length you see fit, no restriction is in place for length.
    
    .EXAMPLE
    PS>Call-RandomPassword -Count 10
    
    #>
        param(
            [Parameter(Mandatory=$True)]
            $Length
        )
        [array]$characters = 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
                      '1','2','3','4','5','6','7','8','9','0',
                      'A','B','C','D','E','F','G','H','J','I','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                      '!','@','#','$','%','^','&','*','(',')'
        $pw = ($characters | Get-Random -count $Length) -join ''
        $pw
        $pw | clip
    }
    
    New-Alias rpw Invoke-RandomPassword
    Export-ModuleMember -Function Invoke-RandomPassword
    Export-ModuleMember -Alias rpw