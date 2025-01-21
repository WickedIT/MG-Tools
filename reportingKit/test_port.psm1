#using module .\Polling.psm1
function Test-Ports {
    param(
        [Parameter(Mandatory)][string]$IP
    )
    $VerbosePreference= 'Continue'
    try {
        if ((Test-Connection -ComputerName $IP -Ping -Count 1).Status -eq 'Success') {
            $portcheck = New-Object System.Collections.ArrayList
            1..65535 | Foreach-object -ThrottleLimit 500 -Parallel  {
                    $device = $using:IP
                    try {
                        $scan = [Net.Sockets.TCPClient]::new().ConnectAsync($device,$_).Wait(500)
                        if ($scan) {
                            $status = [Ordered]@{
                                Device = $device
                                Status = $scan
                            }
                        }
                        $portcheck.Add($status)
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