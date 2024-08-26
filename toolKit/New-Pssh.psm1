<#
Possibly build more functions to make push/pull of data easier
#>

function New-Pssh{
<#

#>
    param(
        $VerbosePreference = 'Continue',
        [Parameter(Position=0,
                   Mandatory=$True
        )]
        [string]$username,
        [Parameter(Position=1,
                   Mandatory=$True
        )]
        [Alias("IP")]
        [string]$computername,
        [Parameter(Position=2,
                   Mandatory=$False
        )]
        [int]$port=22,
        [Parameter(Position=3,
                   Mandatory=$False
        )]
        [string]$keyFilePath="$env:USERPROFILE\.ssh\id_rsa",
        [string]$path,
        [string]$command
    )
    try {
        $SshOptions = @{
            HostName    = "$computername"
            UserName    = "$username"
            Port        = "$port"
            KeyFilePath = "$keyFilePath"
        }
        $SShSession = New-PsSession @SshOptions -ErrorAction Stop
        Write-Output "SSH connection established for '$computername' and is $($SShSession.Availability)"
    }
    catch{
        Write-Error "Connection to endpoint:'$computername' failed. : $_"
        return
    }
}
New-Alias pssh New-Pssh
Export-ModuleMember -Function New-Pssh
Export-ModuleMember -Alias pssh
 