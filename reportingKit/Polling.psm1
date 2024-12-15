class Custom_Polling {
    [string]$Device
    [string]$Status

    Custom_Polling([string]$Device) {
        $this.Device = $Device
        $this.Pulse()
    }

    [void] Pulse() {
        $this.Status = [Custom_Polling]::Test($this.Device)
    }

    [string] static Test([string]$Device) {
        $socket_Build   = [Net.Sockets.TCPClient]::new()
        $socket_Connect = $socket_Build.ConnectAsync($Device,22)
        $state = $socket_Connect.Wait(500)
        return $state
    }
}
function Invoke-Polling {
    param (
        [Parameter(Mandatory=$False)]
        [ValidateScript ({Test-Path $_})]
        [System.IO.FileInfo]$Path,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$True
        )][string]$Device
    )
    if($path) {
        try {
            $Devices = Get-Content -Path $Path
            try {
                $obj = New-Object System.Collections.ArrayList
                foreach ($Dev in $Devices) {
                    $poll = [Custom_Polling]::new($Dev)
                    $obj.Add($poll) | Out-Null
                }
            }
            catch {
                Write-Error "Please provide a valid list of devices : $_"
            }
        }
        catch {
            Write-Error "Please provide a valid path. You provided: $Path"
        }
    }
    else {
        $obj = [Custom_Polling]::new($Device)
    }
    
    Write-Output $obj

}