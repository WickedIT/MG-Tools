function Get-PCUptime {
    param(
        $VerbosePreference = 'SilentlyContinue',
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        [Alias("Name")]
        $computername=$env:COMPUTERNAME,
        [Parameter(
            Mandatory=$False
        )]
        $Log
    )
    #Provide easy uptime stats for localhost or remote pc's. 
    #Including day and time of last boot and hours since last boot
    BEGIN {
        #
        $date = Get-Date
        $lastBootLogs = @()
    }
    PROCESS {
        if ($computername -eq "$env:COMPUTERNAME") {$local = $true}
        else{$local = $false}
        if ($local) {
            try {
                $lastboot = $((Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime)
                Write-Verbose "Collected OS info for '$Computername'..."
                #
                $uptime = $date - $lastboot
                $objProperties = [Ordered]@{
                    Computername = "$Computername"
                    LastBootTime = "$lastboot"
                    Uptime       = "$([int]$uptime.TotalHours) Hrs"
                }
            }
            catch {
                Write-Error "Unable to collect OS info for local computer: $_"
            }
        } 
        else {
            try {#Start cimsession to the computer
                $ping = Test-NetConnection -ComputerName $computername -CommonTCPPort WINRM -ErrorAction Stop
                if (-not $ping.TcpTestSucceeded) {
                    throw "Connection not available over WINRM"
                }
                try {
                    Write-Verbose "Attempting to open a CimSession to the remote computer '$computername'..."
                    $session = New-CimSession -ComputerName $computername -Credential $credential -ErrorAction Stop
                    #
                    try {#Grabs the value for the last boot up time for the computer.
                        $lastboot = (Get-CimInstance -CimSession $session -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
                        Write-Verbose "Collected OS info for '$computername'..."
                        #
                        $uptime = $date - $lastboot
                        $objProperties = [Ordered]@{
                            Computername = "$computername"
                            LastBootTime = "$lastboot"
                            Uptime       = "$([int]$uptime.TotalHours) Hrs"
                            Status       = "Available"
                        }
                    }
                    catch {
                        Write-Error "Unable to collect OS info for remote computer '$computername': $_"
                    }
                }
                catch {
                    Write-Error "Unable to start session to '$computername': $_"
                }
            }
            catch {
                Write-Error $_
                $objProperties = [Ordered]@{
                    Computername = "$computername"
                    LastBootTime = "Unavailable"
                    Uptime       = "Unavailable"
                    Status       = "Unavailable"
                }
            }
            
            finally {
                if ($session) {
                    $session | Remove-CimSession
                }
            }
        }   
        $obj = New-Object -TypeName psobject -Property $objProperties
        $obj | Tee-Object -Variable lastBootLogs | Write-Output     
    }
    END {
        if ($Log) {
            if (Test-Path $log) {
                $lastBootLogs | Add-Content -Path -Append $log
            }
        }
    }
}