function Get-StorageHealth {
    param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    $Computername
    )
    if ($computername -eq '') {
        try {
            $sysdisks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop
            Write-Verbose "Disk information collected from '$computername'."
        }
        catch {
            Write-Error "Unable to collect disk info. | Please debug... : $_"
            return
        }
    }
    else {
        try {
            $CimSession = New-CimSession -ComputerName $computername -ErrorAction Stop
            Write-Verbose "Started Cimsession for '$computername'."
            try {
                $sysdisks = Get-CimInstance -CimSession $CimSession -ClassName Win32_LogicalDisk -ErrorAction Stop
                Write-Verbose "Disk information collected from '$computername'."
            }
            catch {
                Write-Error "Unable to collect disk info from '$computername'. | Please debug... : $_"
                return
            }
        }
        catch {
            Write-Error "Unable to start CimSession. | Please debug... : $_"
            return
        }
        finally {
            $CimSession | Remove-CimSession
            Write-Verbose "Removed Cimsession from cache for '$computername'."
        }
    }
    foreach ($disk in $sysdisks) {
        $avail = ($disk.FreeSpace / $disk.Size) * 100 -as [int]
        $properties = [Ordered]@{
            DEV     = "$($CimSession.Computername)"
            ID      = "$($disk.DeviceID)"
            P_FREE  = "$avail"
            FS      = "$($disk.FileSystem)"
        }
        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj
    }
}