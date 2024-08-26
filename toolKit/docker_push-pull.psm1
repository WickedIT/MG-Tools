<#
Might pivot this to aid the Add-pssh module. Script is currently to specific and needs to be modularized.
#>

function Import-Dockercompose {
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
        [Parameter(Position=2,
                   Mandatory=$False,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $stack
    )
    $local_repo = "C:\admin\The_Vault\DockerMFG\"
    if ($stack) {
        $local_dest = "$local_repo\$($stack)_$($computername)_docker-compose.yaml"
        $remote_dest = "/home/$username/$stack/$($stack)_docker-compose.yaml"
    }
    else {
        $local_dest = "$local_repo\$($computername)_docker-compose.yaml"
        $remote_dest = "/home/$username/docker-compose.yaml"
    }
    Write-Output "Local dest: $local_dest"
    Write-Output "Remote dest: $remote_dest"
    Write-Output "Attempting to connect to '$computername' as '$username' in $stack"
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
    try {
        Copy-Item $local_dest -Destination $remote_dest -ToSession $SShSession
        #scp.exe $local_dest $username@$($computername).mfgwickedit.com:$remote_dest
        Write-Verbose "Success:Git compose file imported to server: '$computername'"
    } catch {
        Write-Verbose "Error:Git compose file not migrated to server: '$computername'."
    }

#scp $username@$computername.mfgwickedit.com:$pull_source $pull_destination
}
Export-ModuleMember Import-Dockercompose

function Export-Dockercompose {
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
        [Parameter(Position=2,
                   Mandatory=$False,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $stack
    )
    $date = Get-Date
    $local_repo = "C:\admin\The_Vault\DockerMFG\"
    $local_dest = "$local_repo\ubuntu_pull\$computername\$($date.Dayofyear)\"
    if (Test-Path $local_dest){
    }
    else {New-Item -ItemType Directory -Item $local_dest}

    if ($stack) {
        if (Test-path $local_dest\$stack){
            $local_dest = "$local_dest\$stack"
        }
        else {
            $local_dest = New-Item -ItemType Directory -Item $local_dest\$stack
        }
        $local_yaml = "$local_repo\$($stack)_$($computername)_docker-compose.yaml"
        $remote_dest= "/home/$username/$stack/$($stack)_docker-compose.yaml"
            
        }
    else {
        $local_yaml = "$local_repo\$($computername)_docker-compose.yaml"
        $remote_dest= "/home/$username/docker-compose.yaml"
    }
    if($stack){}else{$stack='Parent'}
    Write-host "Attempting to connect to '$computername' as '$username' in $stack"
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
    try {
        Copy-Item $remote_dest -Destination $local_dest\pulled_compose.yaml -FromSession $SShSession -ErrorAction Stop
        #scp $username@$computername.mfgwickedit.com:$remote_dest $local_dest/pulled_compose.yaml -ErrorAction Stop
        Write-Verbose "Success:Source file exported from server: $computername at user $username"
    } 
    catch {
        Write-Verbose "Error: Source file did not export from server: $computername at user $username"
    }
    $Test_pull = Test-path $local_dest/pulled_compose.yaml
    if ($Test_pull) {
        try {
            Copy-Item -Path $local_yaml -Destination $local_dest -ErrorAction Stop
            Write-Verbose "Success:Git compose file archived for server '$computername'."
            $Continue = $True
        } catch{
            Write-Verbose "Error:Git compose file not archived for server '$computername'."
            $Continue = $False 
        }
    }
    if ($Continue) {
        try {
            Remove-Item -Path $local_yaml -ErrorAction Stop
            Write-Verbose "Success:Git compose file removed for server '$computername'."
        } catch {
            Write-Verbose "Error:Git compose file not removed for server '$computername'."
        }
        try {
        Copy-Item -Path "$local_dest\pulled_compose.yaml" -Destination "$local_yaml" -ErrorAction Stop
        Write-Verbose "Success:Compose file from '$computername' migrated to Git."
        } 
        catch {
            Write-Verbose "Error:Compose file failed to migrate from archive to Git for server '$computername'."
        }
    }
}
Export-ModuleMember Export-Dockercompose