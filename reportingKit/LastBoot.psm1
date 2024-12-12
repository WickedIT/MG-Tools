function Get-PCUptime {
    param(
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
        [string]$Log
    )
    #Provide easy uptime stats for localhost or remote pc's. 
    #Including day and time of last boot and hours since last boot
    BEGIN {
        #
        $date = Get-Date
        $lastBootLogs = @()
    }
    PROCESS {
        try {
            if ($computername -eq "$env:COMPUTERNAME") {$local = $true}
            else{$local = $false}
            if ($local) {
                $lastboot = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
                Write-Verbose "Collected OS info for '$Computername'..."
            }
            else {
                try {
                    if (([Net.Sockets.TCPCLient]::new()).ConnectAsync($Computername, '5985').Wait(500)) {
                        Write-Verbose "Attempting to open a CimSession to the remote computer '$computername'..."
                        $session = New-CimSession -ComputerName $computername -Credential $credential -ErrorAction Stop
                        $lastboot = (Get-CimInstance -CimSession $session -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
                    }
                }
                catch {
                    Write-Error "Unable to access remote computer : $_"
                }
            }
            $uptime = $date - $lastboot
            $objProperties = [Ordered]@{
                Computername = "$computername"
                LastBootTime = "$lastboot"
                Uptime       = "$([int]$uptime.TotalHours) Hrs"
                Status       = "Available"
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
        $obj = New-Object -TypeName psobject -Property $objProperties
        $obj | Tee-Object -Variable lastBootLogs | Write-Output     
    }
    END {
        if ($Log) {
            if (!(Test-Path $log)) {
                New-Item -Path $Log
            }
            $lastBootLogs | Add-Content -Path $log -Append 
        }
    }
}