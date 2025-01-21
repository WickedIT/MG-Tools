#using module .\Polling.psm1
function Test-Ports {
    param(
        [Parameter(Mandatory)][string]$IP
    )
    $VerbosePreference= 'Continue'
    try {
        if ((Test-Connection -ComputerName $IP -Ping -Count 1).Status -eq 'Success') {
            $portcheck = 1..65535 | Foreach-object -ThrottleLimit 1000 -Parallel {
                $device = $using:IP
                $port   = $_
                try {
                    $scan = [Net.Sockets.TCPClient]::new().ConnectAsync($device,$port).Wait(500)
                    if ($scan) {
                        $status = [PSCustomObject]@{
                            Device = $device
                            Port   = $port
                            Status = 'Listening'
                        } | Format-Table
                    }
                    Write-Verbose "Scanning Port : $_"
                }
                catch{
                    Write-Error "Unable to scan port : $_"
                }
                finally {
                    Write-Output $status
                }
            } -AsJob | Receive-Job -Wait
            Write-Verbose "The port scan is complete on host: $IP"
        }
        else {
            throw "Unable to establish a connection to the computer : $_"
        }
    }
    catch {
        Write-Error $_
    }
    finally {
        Write-Output $portcheck
    }
}