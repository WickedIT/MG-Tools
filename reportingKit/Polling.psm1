[NoRunspaceAffinity()]
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
function Invoke-Polling {
    param (
        [Parameter(Mandatory=$False)][ValidateScript ({Test-Path $_})]
        [System.IO.FileInfo]$Path,
        #
        [Parameter(ValueFromPipeline=$True)]
        [string]$Device,
        #
        [Parameter()][switch]$SSH,
        #
        [Parameter()][switch]$WINRM
    )
    if(($SSH) -and (! $WINRM)){$port=22}
    #
    elseif(($WINRM) -and (! $SSH)){$port=5985}
    #
    else{$port=$null}
    #
    if($null -eq $port) {
        $port=22
        Write-Warning "No port selected, using default port '$port'"
    }
    Write-Verbose "Port used for device(s): '$port'"
    if($path) {
        try {
            $Devices = Get-Content -Path $Path
            try {
                $obj = New-Object System.Collections.ArrayList
                foreach ($Dev in $Devices) {
                    $obj.Add([Custom_Polling]::new($Dev,$port)) | Out-Null
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
    elseif ($device) {
        $obj = [Custom_Polling]::new($Device,$port)
    }
    else {
        Write-Error "Please provide a device to poll."
    }
    Write-Output $obj

}
