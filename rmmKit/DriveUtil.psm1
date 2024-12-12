function Optimize-Drive {
<#
needs work
#>
param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    [string]$computername=$env:COMPUTERNAME,
    [Parameter(
        Mandatory=$false
    )]
    [switch]$log
    )
    BEGIN {
        $date = Get-Date -Format "MM_DD_YYYY"
        if ($log) {
            $logfile = "$PSScriptRoot\$date-optimize_drive_output.txt"
            try {
                $CompDriveFull = New-Item -Path $logfile -ErrorAction Continue
                Write-Verbose "Created file '$logfile'"
            }
            catch {
                Write-Error "Unable to create log file - '$logfile'. : $_"
            }
        }
    }
    PROCESS {
        if ($computername -eq $env:COMPUTERNAME) {
            try {
                $health = Get-StorageHealth -ErrorAction Stop | Where-Object -Property ID -eq "C:" | Select-Object -ExpandProperty P_FREE
                Write-Verbose "Percent free for disk 'C' on $computername has been collected"
            }
            catch {
                Write-Error "Unable to collect storage health for '$computername'. Please debug... : $_"
            }
            if ($health -lt 80) {
                try {
                    Invoke-DiskCleanUtil -ErrorAction Stop
                    if ($health -lt 20) {
                        $computername | Out-File -Append -FilePath $CompDriveFull
                    }
                }
                catch {
                    Write-Error "Unable to run the disk utility on '$computername'. Please debug : $_"
                }
            }
        }
        else {
            foreach ($computer in $computername) {
                try {
                    $health = Get-StorageHealth -computername $computer | Where-Object -Property ID -eq "C:" | Select-Object -ExpandProperty P_FREE
                }
                catch {
                    Write-Error "Unable to collect storage health for '$computername'. Please debug... : $_"
                }
                if ($health -lt 80) {
                    try {
                        Invoke-DiskCleanUtil -computername $computer
                        if ($health -lt 20) {
                            $computername | Out-File -Append -FilePath $CompDriveFull
                        }
                    }
                    catch {
                        Write-Error "Unable to run the disk utility on '$computername'. Please debug : $_"
                    }
                }
            }
        }
    }
    END {

    }
}
function Set-DriveCleanupOptions{
    $CurrentItemSet = @{
        Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*'
        Name        = 'StateFlags0001'
        ErrorAction = 'SilentlyContinue'              
    }
    Get-ItemProperty @CurrentItemSet `
        | Remove-ItemProperty `
            -ErrorAction SilentlyContinue #Pushes the StateFlag001 switch to be removed from every subpath in VolumeCaches if it exists
    $Switches = @(
        'Active Setup Temp Folders',
        'BranchCache',
        'Content Indexer Cleaner',
        'Device Driver Packages',
        'Downloaded Program Files',
        'GameNewsFiles',
        'GameStatisticsFiles',
        'GameUpdateFiles',
        'Internet Cache Files',
        'Memory Dump Files',
        'Offline Pages Files',
        'Old ChkDsk Files',
        'Previous Installations',
        'Recycle Bin',
        'Service Pack Cleanup',
        'Setup Log Files',
        'System error memory dump files',
        'System error minidump files',
        'Temporary Files',
        'Temporary Setup Files',
        'Temporary Sync Files',
        'Thumbnail Cache',
        'Update Cleanup',
        'Upgrade Discarded Files',
        'User file versions',
        'Windows Defender',
        'Windows Error Reporting Archive Files',
        'Windows Error Reporting Queue Files',
        'Windows Error Reporting System Archive Files',
        'Windows Error Reporting System Queue Files',
        'Windows ESD installation files',
        'Windows Upgrade Log Files'
        #Puts all DiskClean switches into a variable
    )
    foreach ($Switch in $Switches) {
        $newItemSet = @{
            Path         = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$switch"
            Name         = 'StateFlags0001'
            Value        = 1
            PropertyType = 'DWord'
            ErrorAction  = 'SilentlyContinue'
            #Sets the new details for the StateFlags001 switch
        }
        New-ItemProperty @newItemSet | Out-Null # applies newitemset to each folder in volumecaches
    }
}
function Invoke-DiskCleanUtil {
    param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    $computername=$env:COMPUTERNAME
    )
    if ($computername -eq $env:COMPUTERNAME) {
        try {
            Set-DriveCleanupOptions -ErrorAction Stop
            Write-Verbose "Enabled all flags for CleanMgr to clear anything it can on : '$computername'"
            try {
                Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle 'Hidden' -ErrorAction Stop
                Write-Verbose "Successfully executed CleanMgr on '$computername'."
            }
            catch {
                Write-Error "Unable to start process for CleanMgr. Please debug... : $_"
                return
            }
        }
        catch {
            Write-Error "Unable to set flags for CleanMgr to run completely. Please debug : $_"
                return
        }
    }
    else {
        try {
            $session = New-PSSession -ComputerName $computername
            Write-Verbose "Opened PSSession to '$computername'."
            try {
                Invoke-Command -Session $session -ScriptBlock ${function:Set-DriveCleanupOptions}
                Write-Verbose "Enabled all flags for CleanMgr to clear anything it can on : '$computername'"
                try {
                    Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle 'Hidden'}
                    Write-Verbose "Successfully start CleanMgr on '$computername'."
                }
                catch {
                    Write-Error "Unable to start CleanMgr on '$computername'. Please debug : $_ "
                    return
                }
            }
            catch {
                Write-Error "Unable to set flags for CleanMgr to run completely. Please debug : $_"
                return
            }
        }
        catch {
            Write-Error "Unable to start a session to '$computername'. Please debug... : $_"
            return
        }
        finally {
            $session | Remove-PSSession
            Write-Verbose "Removed PSSession from cache for '$computername'."
        }
    }
}