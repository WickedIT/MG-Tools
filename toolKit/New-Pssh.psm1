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
        Write-Host "SSH connection established for '$computername' and is $($SShSession.Availability)"
        Write-Output $SShSession
    }
    catch{
        Write-Host "Connection to endpoint:'$computername' failed. Exiting..."
        Write-Ouput $SShSession
        return
    }
    if ($SShSession.Availability -eq 'Available') {
        $Enter = Read-Host "The session for '$computername' was created, would you like to connect now? (Y/n)"
        if ($Enter.ToUpper() -eq 'Y') {
            Enter-PSSession -id $SShSession.ID
        }
        else {return}
    }
}
New-Alias pssh New-Pssh
Export-ModuleMember -Function New-Pssh
Export-ModuleMember -Alias pssh
 