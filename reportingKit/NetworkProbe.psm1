function Get-IpRange {
    param([Parameter(Mandatory,ValueFromPipeline)]$HostIP)
    #
    try {
        $adapter = Get-NetIPAddress -AddressFamily IPv4 | Where-Object -Property IPAddress -Match "$HostIP"
        #
        if ($null -ne $adapter) {
            #Convert IPAddress to bytes
            $hostIpBytes = ([System.Net.IpAddress]::Parse($adapter.IPAddress)).GetAddressBytes()
            [array]::Reverse($hostIpBytes)
            $ipInt = [System.BitConverter]::ToUInt32($hostIpBytes, 0)
            
            #Convert PrefixLength to bytes
            $maskInt = [UInt32]::MaxValue -shl (32 - $adapter.PrefixLength)
            
            #Calculate and convert network address to bytes
            $networkInt = $ipInt -band $maskInt
            
            # Calculate and convert $broadcast address to bytes
            $broadcastInt = $networkInt -bor (-bnot $maskInt -band [uint32]::MaxValue)
            
            #Output range of IP's in subnet
            $range = [System.Collections.ArrayList]::new()
            for ($i = $networkInt + 1; $i -lt $broadcastInt; $i++) {
                $ipBytes = [System.BitConverter]::GetBytes($i)
                [array]::Reverse($ipBytes)
                $ipAddress = [System.Net.IPAddress]::new($ipBytes)
                $range.Add($ipAddress.ToString())
            }
        }
        else {
            throw "Please provide the IPAddress for the interface you would like to scan."
        }
    }
    catch {
        Write-Error $_
    }
    finally {
        Write-Output $range
    }
}

function Test-PortRange {
    param(
        [Parameter(Mandatory, Position=0)]
            [string]$IP,
        [Parameter(Mandatory, Position=1)]
        [ValidateSet("FullRange","Top1000","Custom")]    
            [string]$PortRange
    )
    try {
        if ((Test-Connection -ComputerName $IP -Ping -Count 1).Status -eq 'Success') {
            $ports = [System.Int32[]]
            switch ($portRange) {
                "FullRange" {
                    $ports = 1..65535
                }
                "Top1000" {
                    $ports = (Get-Content "$PSScriptRoot\top_port_list.txt" -Raw).split(', ')
                }
                "Custom" {
                    $ports = Read-Host "Please enter a range of ip addresses."
                }
            }
            $portcheck = $ports | Foreach-object -ThrottleLimit 100 -Parallel {
                 $device = $using:IP
            [int]$port   = $_
                try {
                    $socket = [Net.Sockets.TCPClient]::new()
                    $scan = $socket.ConnectAsync($device,$port).Wait(1)
                        if ($scan) {
                            $status = [PSCustomObject]@{
                                Port   = $port
                                Status = 'Listening'
                            }
                        }
                    Write-Verbose "Scanning Port : $_"
                }
                catch{
                    Write-Error "Unable to scan port : $_"
                }
                finally {
                    Write-Output $status
                    $socket.Close()
                }
            } -AsJob | Receive-Job -Wait
        }
        else {
            throw "Unable to establish a connection to the computer : $_"
        }
    }
    catch {
        Write-Error $_
    }
    finally {
        Write-OutPut "#"
        Write-Output "Scan complete for : $IP"
        Write-Output $portcheck
    }
}

#

function Invoke-NetworkProbe {
    param(
        [Parameter(Mandatory,Position=0)]
            [string]$HostIP,

        [Parameter(Mandatory, Position=1)]
        [ValidateSet("FullRange","Top1000","Custom")]    
            [string]$PortRange
    )
    [array]$IpRange = Get-IPRange -HostIP $HostIP
    $IpRange | ForEach-Object -ThrottleLimit 50 -Parallel {
        $scan = Test-PortRange -IP "$using"
    }
}