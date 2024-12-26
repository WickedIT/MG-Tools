function Get-PCUptime {
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True
        )]
        [Alias("Name")]
        $computername=$env:COMPUTERNAME,
        [Parameter()]
        [string]$Logging
    )
    #Provide easy uptime stats for localhost or remote pc's. 
    #Including day and time of last boot and hours since last boot
    BEGIN {
        #
        $date = Get-Date
    }
    PROCESS {
        try {
            if ($computername -eq "$env:COMPUTERNAME") {
                $lastboot = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
                Write-Verbose "Collected OS info for '$Computername'..."
            }
            else {
                if ((Invoke-Polling -Device $Computername -WINRM).Status) {
                    Write-Verbose "Attempting to open a CimSession to the remote computer '$computername'..."
                    $session = New-CimSession -ComputerName $computername -Credential $credential -ErrorAction Stop
                    $lastboot = (Get-CimInstance -CimSession $session -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
                }
                else {
                    throw "$_"
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
            $obj = New-Object -TypeName psobject -Property $objProperties
            Write-Output $obj 
        }    
    }
    END {
        if ($Logging) {
            if (!(Test-Path $logging)) {
                New-Item -Path $Logging
            }
            $obj | Add-Content -Path $loging
        }
    }
}