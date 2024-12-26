#Requires -Modules Polling
<#
Possibly build more functions to make push/pull of data easier
#>

function New-Pssh{

    param(
        [Parameter(Position=0,Mandatory)]
        [string]$username,
        [Parameter(Position=1,Mandatory)][Alias("IP")]
        [string]$computername,
        [Parameter(Position=2)]
        [int]$port=22,
        [Parameter(Position=3)]
        [string]$keyFilePath="$env:USERPROFILE\.ssh\id_rsa",
        [Parameter()]
        [switch]$Persistent,
        [Parameter()]
        $Command
    )
    try {
        $SshOptions = @{
            HostName    = "$computername"
            UserName    = "$username"
            Port        = "$port"
            KeyFilePath = "$keyFilePath"
        }
        if ([Custom_Polling]::new($computername,$port).Status) {
            $SShSession = New-PsSession @SshOptions -ErrorAction Stop
            Write-Verbose "Establishing connection to '$computername' over SSH..."
        }
        else {
            throw "'$computername' not online or SSH port down."
        }
    }
    catch{
        Write-Error "Connection to endpoint:'$computername' failed. : $_"
    }
    finally {
        if ($null -ne $SShSession) {   
            try {
                if ((! $Persistent) -and ([string]::IsNullOrWhiteSpace($command))) {
                    Write-Output $SShSession
                }
                elseif ((! [string]::IsNullOrWhiteSpace($command)) -and (! $Persistent)) {
                    $command_result = Invoke-Command -Session $SShSession -ScriptBlock {
                        Invoke-Expression -Command $using:Command
                    } -ErrorAction Continue
                    Write-Verbose "Executing '$command' on device '$computername'"
                }
                elseif ($Persistent -and ([string]::IsNullOrWhiteSpace($command))) {
                    Enter-PSSession -Id $SShSession.ID -ErrorAction Continue
                }
                else {
                    throw "'Persistent' & 'Command' are mutually exclusive."
                }
            }
            catch {
                Write-Error $_
            }
            finally {
                if ((-not [string]::IsNullOrWhiteSpace($command))) {
                    Write-Output $command_result
                    Remove-PSSession -Id $SShSession.ID
                }
            }
        }
        else {
            Write-Error "There was an issue : $_"
        }
    }
}
New-Alias -Name 'pssh' -Value New-Pssh