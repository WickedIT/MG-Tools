function Get-StorageHealth {
    param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    $Computername=$env:COMPUTERNAME
    )
    try {
        if ($computername -eq $env:COMPUTERNAME) {
            $sysdisks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop
            Write-Verbose "Disk information collected from '$computername'."
        }
        else {
            if ((Invoke-Polling -Device $Computername -WINRM).Status) {
                $CimSession = New-CimSession -ComputerName $computername -ErrorAction Stop
                Write-Verbose "Started Cimsession for '$computername'."
            }
            else {
                throw "WinRM not enabled. Please resolve."
            }
            $sysdisks = Get-CimInstance -CimSession $CimSession -ClassName Win32_LogicalDisk -ErrorAction Stop
        }
    }
    catch {
        Write-Error "Unable to collect disk info. | Please debug... : $_"
    }
    finally {
        if($null -ne $CimSession) {
            $CimSession | Remove-CimSession
            Write-Verbose "Removed Cimsession from cache for '$computername'."
        }
    }
    foreach ($disk in $sysdisks) {
        $avail = ($disk.FreeSpace / $disk.Size) * 100 -as [int]
        $properties = [PSCustomObject]@{
            DEV     = "$($Computername)"
            ID      = "$($disk.DeviceID)"
            P_FREE  = "$avail %"
            FS      = "$($disk.FileSystem)"
        }
        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj
    }
}