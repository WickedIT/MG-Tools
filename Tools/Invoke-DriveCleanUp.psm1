<#
Run DiskCleanup on remote machines or localhost
###########################################################################
#>

function Set-DriveCleanupOptions {
    BEGIN {
        $CurrentItemSet = @{
                        Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*'
                        Name        = 'StateFlags0001'
                        ErrorAction = 'SilentlyContinue'
                        
        }
        Get-ItemProperty @CurrentItemSet |`
            Remove-ItemProperty `
            -Name StateFlags0001 `
            -ErrorAction SilentlyContinue #Pushes the StateFlag001 switch to be removed from every subpath in VolumeCaches if it exists

    }
    PROCESS {
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
    END {
    }
}


function Invoke-DriveCleanUpWorkerFunction {
    param(
        $VerbosePreference = 'Continue',
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $computername
    )
    BEGIN {
        $lastboot = Get-CimInstance `
                        -ClassName Win32_OperatingSystem |`
                            Select-Object `
                            -ExpandProperty LastBootUpTime #grabs time since last boot
        $currentdate = Get-Date
        $continue = $false
        $restart = $false
        if (($currentdate - $lastboot | Select-Object -ExpandProperty 'TotalHours') -lt '168') { #checks to see if Lastbootuptime is less than 48 hours
            $continue = $true
        }
        else {
            $restart = $true
        }

    }
    PROCESS {
        if ($restart) { #if lastboot is greater than 0 days, prompt for restart
                Write-Verbose "This computer: '$computername' needs to be restarted before continuing."
                $yesorno = Read-Host "Do you want to restart? For yes (y) for no (n)"
                if ($yesorno -eq 'y') {
                    Shutdown.exe /r /f
                }
                else {
                Write-Verbose "Please restart computer: '$computername' when available, and run the script again."
                }
        }
        $disks = Get-CimInstance `
                    -ClassName Win32_LogicalDisk `
                    -Filter "DeviceID='C:'" #get primary disk info
   [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int] #take disk info and form it into percentage
        if ($continue) {  #if lastboot is = 0 then run disk cleanup
            if ($percentavail -in 11..80) { #if the integer of percentleft fits into range, run clean
                #Run Disk Cleanup
                Start-Process `
                    -FilePath CleanMgr.exe `
                    -ArgumentList '/sagerun:1' `
                    -WindowStyle Hidden #/sagerun:1 runs the StateFlags001 switches
                Write-Verbose "Drive Percent Left is: '$percentavail', make necessary changes to Disk Clean Tool options."
            }
            elseif ($percentavail -in 0..10) { #if the integer of percentleft fits into this range as well, prompt for further discovery
                $computername |
                    Out-File -FilePath .\Comp_Drive_Full.txt -Append
                Write-Verbose "Check the Comp_Drive_Full text file."
            }
            
        }
    }
    END {
    }
}

function Invoke-DriveCleanUp {
<#
.SYNOPSIS
Automates minor disk cleanup.

.DESCRIPTION
This CMDlet collects information about "C" drive of a computer local or otherwise. This includes objects passed through the pipeline. After collecting the information the CMDlet determines whether the computer needs to be restarted, trimmed, or if it needs further attention.

.PARAMETER computername
Specifies the computername variable. No default value but 'localhost' is accepted.

.EXAMPLE
PS> Invoke-DriveCleanUp -computername 'localhost'

.EXAMPLE
PS> Get-ADComputer -filter "name -like '*'" | Invoke-DriveCleanUp

#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
    [Parameter(Mandatory=$False,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True
    )]
    [Alias("Name")]
    $computername='localhost'
    )
    BEGIN {
        $credential = Get-Credential -Message "If not Q'ing AD computers, ignore credential request." #get credential or ignore if localhost
        $date = Get-Date
        Remove-Item .\Comp_No_Connection.txt -ea SilentlyContinue
        Remove-Item .\Comp_Drive_Full.txt -ea SilentlyContinue
        
    }
    PROCESS {
        if ($computername -ne 'localhost') { #if querying several computers, try running sessions
            foreach ($computer in $computername) {
                try{$ping = Test-NetConnection `
                                -ComputerName $Computer `
                                -CommonTCPPort WinRM
                }
                catch {
                    $computer | Out-File Comp_No_Connection.txt -Append
                    $properties = [Ordered]@{Computername = "$computer"
                                             Status       = "Disconnected or Blocked"
                                             }
                
                }
                    
                    if ($ping.TcpTestSucceeded) {#test TCP connection
                        $session = New-PSSession `
                                        -ComputerName $computer `
                                        -Credential $credential `
                                        -ea SilentlyContinue #new pssession
                        $cimsession = New-CimSession `
                                        -ComputerName $computer `
                                        -Credential $credential `
                                        -ea SilentlyContinue #new cimsession
                        $lastboot = Get-CimInstance `
                                        -ClassName Win32_OperatingSystem `
                                        -CimSession $cimsession |
                                            Select-Object `
                                            -ExpandProperty LastBootUpTime #grab last boot up time
                        $TotalHrs = ($date - $lastboot).TotalHours -as [int]
                        $disks = Get-CimInstance `
                                        -ClassName Win32_LogicalDisk `
                                        -CimSession $cimsession `
                                        -Filter "DeviceID='C:'" #grab primary disk info
                        [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int] #convert disk available to percentage
                        $properties = [Ordered]@{Computername = "$computer"
                                                Status       = "Connected"
                                                DriveAvail   = "% $percentavail"
                                                Uptime       = "$TotalHrs Hours"
                                                }
                    } 
                    else {
                        $properties = [Ordered]@{Computername = "$computer"
                        Status       = "Ping Failed"
                        DriveAvail   = "N/A"
                        Uptime       = "N/A"
                        }
                    }#display computer info in an object

                    $obj = New-Object -TypeName psobject -Property $properties
                    Write-Output $obj #display alternate computer info for failed computers
                    
                    Invoke-Command `
                        -Session $session `
                        -ScriptBlock ${function:Set-DriveCleanupOptions} #preps the sagerun switches with invoke-command
                    Invoke-Command `
                        -Session $session `
                        -ScriptBlock ${function:Invoke-DriveCleanUpWorkerFunction} `
                            -ArgumentList $Computer #runs the function for disk cleanup with invoke-command
            }
        }
        else { #if running against localhost, output and function is essentially the same just shortened           
            $lastboot = Get-CimInstance `
                            -ClassName Win32_OperatingSystem |
                                Select-Object `
                                -ExpandProperty LastBootUpTime
            $TotalHrs = ($date - $lastboot).TotalHours -as [int]
            $disks = Get-CimInstance `
                            -ClassName Win32_LogicalDisk `
                            -Filter "DeviceID='C:'"
            [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int]
            $properties = [Ordered]@{Computername = "$computername"
                                     Status       = "Connected"
                                     DriveAvail   = "% $percentavail"
                                     Uptime       = "$TotalHrs HoursN"
                                     }
            $obj = New-Object `
                        -TypeName psobject `
                        -Property $properties
            Set-DriveCleanupOptions
            Invoke-DriveCleanUpWorkerFunction `
                        -computername $computername
            Write-Output $obj
        }
    }
    END {
    }
}
<#
###########################################################################
#>

New-Alias cleanup Invoke-DriveCleanUp
Export-ModuleMember -Function Invoke-DriveCleanUp
Export-ModuleMember -Alias cleanup