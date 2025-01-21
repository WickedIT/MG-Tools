#using module .\Polling.psm1
function Test-Ports {
    param(
        [Parameter(Mandatory)][string]$IP
    )
    $VerbosePreference= 'Continue'
    try {
        if ((Test-Connection -ComputerName $IP -Ping -Count 1).Status -eq 'Success') {
            $portcheck = New-Object System.Collections.ArrayList
            1..65535 | Foreach-object -ThrottleLimit 500 -Parallel {
                    #Defines class
                    class Custom_Polling {
                        [string]$Device
                        [int]$Port
                        [string]$Status
                    
                        Custom_Polling([string]$Device,[int]$port) {
                            $this.Device = $Device
                            $this.Port   = $port
                            $this.Pulse()
                        }
                    
                        [void] Pulse() {
                            $this.Status = [Custom_Polling]::Test($this.Device,$this.Port)
                        }
                    
                        [string] static Test([string]$Device,[int]$port) {
                            $state = [Net.Sockets.TCPClient]::new().ConnectAsync($Device,$port).Wait(500)
                            return $state
                        }
                    }
                    #
                    #
                    #Calls and excutes class
                    try {
                        $portcheck.Add([Custom_Polling]::new("$using:IP", $_))
                        Write-Verbose "Scanning Port : $_"
                    }
                    catch{
                        Write-Error "Unable to scan port : $_"
                    }
                }
            Write-Verbose "The port scan is complete on host: $IP"
        }
        else {
            throw "Unable to establish a connection to the computer : $_"
        }
    }
    catch {
        $portcheck = $null
        Write-Error $_
    }
    finally {
        if ($null -eq $portcheck) {
            $openports = $portcheck | 
            Where-Object -FilterScript {
                $_.Status -eq 'True'
            }
        }
        else {
            $openports = "There was an issue please debug."
        }
        Write-Output $openPorts
    }
}