function Enter-Pssh{
    param(
        $VerbosePreference = 'Continue',
        [Parameter(Position=0,
                   Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $computername,
        [Parameter(Position=1,
                   Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $username,
        $command,
        $path
    )
    try {
        $SshOptions = @{
            Hostname= "$computername"
            UserName= "$username"
            Port=22
            KeyFilePath= "$env:USERPROFILE\.ssh\id_rsa"
        }
        $SShSession = New-PsSession @SshOptions -ErrorAction Stop
        Write-Host "SSH established for '$computername' and is $($SShSession.Availability)"
    }
    catch{
        Write-Host "Connection to endpoint:'$computername' failed. Exiting..."
        return
    }
}