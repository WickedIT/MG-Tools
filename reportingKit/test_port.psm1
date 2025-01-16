#using module .\Polling.psm1
function Test-Port {
    param(
        [Parameter(Mandatory)][string]$IP
    )
    try {
        if ((Test-Connection -ComputerName $IP -Ping -Count 1).Status -eq 'Success') {
            $portcheck = 1..65535 | Foreach-object -ThrottleLimit 500 -Parallel {
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
                    [Custom_Polling]::new("$using:IP", $_)
                }
            Write-Verbose "The port check job has been created. Waiting for scan to complete on IP: $IP"
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
            $portcheck | 
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