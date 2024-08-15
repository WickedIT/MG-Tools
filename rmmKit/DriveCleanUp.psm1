<#
Run DiskCleanup on remote machines or localhost
###########################################################################
#>

function Set-DriveCleanupOptions {
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


function Invoke-DriveCleanUpWorkerFunction {
    if ($continue) {  #if lastboot is = 0 then run disk cleanup
        if ($percentavail -in 11..80) { #if the integer of percentleft fits into range, run clean
            #Run Disk Cleanup
            Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden #/sagerun:1 runs the StateFlags001 switches
            #
            Write-Verbose "Drive Percent Left is: '$percentavail%'."
        }
        elseif ($percentavail -in 0..10) { #if the integer of percentleft fits into this range as well, prompt for further discovery
            $computername | Out-File -FilePath .\Comp_Drive_Full.txt -Append
            Write-Verbose "Check the Comp_Drive_Full text file."
        }
        
    }
}

function Invoke-DriveCleanUp {
<#
.SYNOPSIS
Automates minor disk cleanup.

.DESCRIPTION
This CMDlet collects information about "C" drive of a computer local or otherwise. This includes objects passed through the pipeline. After collecting the information the CMDlet determines whether the computer needs to be restarted, trimmed, or if it needs further attention.

.PARAMETER computername
Specifies the computername variable. The default is 'localhost'.

.EXAMPLE
PS> Invoke-DriveCleanUp -computername 'localhost'

.EXAMPLE
PS> Get-ADComputer -filter "name -like '*'" | Invoke-DriveCleanUp

#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    [Alias("Name")]
    $computername='localhost'
    )
    BEGIN {
        $date = Get-Date -Format "MM_DD_YYYY"
        try {
        New-Item $PSScriptRoot\$($date)_Comp_No_Connection.txt -ea SilentlyContinue
        New-Item $PSScriptRoot\$($date)_Comp_Drive_Full.txt -ea SilentlyContinue
        }
        catch {
            Write-Error "Unable to create Comp_No_Connection or Comp_Drive_Full in the scripts root path. Make sure you have sufficient write privilages to the directory."
        }
        
    }
    PROCESS {
        if ($computername -ne 'localhost') { #if querying several computers, try running sessions
            $credential = Get-Credential #get credential
            try{
                $ping = Test-NetConnection -ComputerName $computername -CommonTCPPort WinRM -ErrorAction Stop
                Write-Verbose "Connection to $computername with WINRM is valid and the protocol resolved as $($ping.TcpTestSucceeded)"
            }
            catch {
                $properties = [Ordered]@{
                    Computername  = "$computername"
                    WinRM_Status  = "$($ping.TcpTestSucceeded)"
                }
                $properties | Out-File Comp_No_Connection.txt -Append
            }
                    
            if ($ping.TcpTestSucceeded) {#test TCP connection
                try {#Open CimSession to computer.
                    $cimsession = New-CimSession -ComputerName $computername -Credential $credential -ErrorAction Stop #new cimsession
                    Write-Verbose "New Cimsession opened for $computername."
                }
                catch {
                    Write-Verbose "Not able to connect to $computername with WSMAN/WINRM"
                    exit
                }
                try {#Grab CimInstance info from computer.
                    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $cimsession -Filter "DeviceID='C:'" -ErrorAction Stop
                }
                catch {
                    Write-Error "Unable to connect to $computername with CimInstance over CimSession"
                    Write-Output $disks
                }
            [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int] #convert disk available to percentage
                $properties = [Ordered]@{
                    Computername = "$computername"
                    Status       = "Connected"
                    DriveAvail   = "% $percentavail"
                }
            } 
            else {
                $properties  = [Ordered]@{
                    Computername = "$computername"
                    Status       = "Ping Failed"
                    DriveAvail   = "N/A"
                }
            }
            #display computer info in an object
            $obj = New-Object -TypeName psobject -Property $properties
            Write-Output $obj #display alternate computer info for failed computers
            try {
                $session = New-PSSession -ComputerName $computername -Credential $credential -ErrorAction Stop
            }
            catch {
                Write-Error "Unable to start a PSSession to '$computername'"
                Write-Output $session
                exit
            }
            #
            try {Invoke-Command -Session $session -ScriptBlock ${function:Set-DriveCleanupOptions} -ErrorAction Stop} #preps the sagerun switches with invoke-command
            catch{Write-Error "Unable to set the Clean Up options"}
            #
            try{Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath CleanMgr.exe} -ArgumentList "'/sagerun:1' -WindowStyle Hidden" -ErrorAction Stop} #runs the function for disk cleanup with invoke-command
            catch {Write-Error "Unable to run the Drive CleanUp utility."}
        }
        else { #if running against localhost, output and function is essentially the same just shortened           
            try {#Grab CimInstance info from computer.
                $lastboot = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cimsession -ErrorAction Stop
                $disks = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $cimsession -Filter "DeviceID='C:'" -ErrorAction Stop
            }
            catch {
                Write-Error "Unable to connect to $computername with CimInstance over CimSession"
                Write-Output $lastboot
                Write-Output $disks
            }
            [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int]
            $properties = [Ordered]@{Computername = "$computername"
                                     Status       = "Connected"
                                     DriveAvail   = "% $percentavail"
                                     }
            try {Set-DriveCleanupOptions -ErrorAction Stop} #preps the sagerun switches
            catch{Write-Error "Unable to set the Clean Up options"}
            #
            try{function:Invoke-DriveCleanUpWorkerFunction -ErrorAction Stop} #runs the function for disk cleanup
            catch {Write-Error "Unable to run the Drive CleanUp utility."}
            
            $obj = New-Object -TypeName psobject -Property $properties
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

function Invoke-Restart {
    param(
    [Parameter(Mandatory=$False,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True
    )]
    $computername='localhost'
    )
    $lastboot = Get-CimInstance -ClassName Win32_OperatingSystem #grabs time since last boot
    $currentdate = Get-Date
    $sinceReboot = $currentdate - $lastboot.LastBootUpTime
    if ($sinceReboot.TotalHours -gt '168') { #checks to see if Lastbootuptime is greater than than 7 days.
        Write-Host "This computer: '$computername' has not been restarted in $($sinceReboot.TotalHours)."
        $YorN = Read-Host "Do you want to restart?(Y/n)"
        if ($YorN.ToUpper() -eq 'Y') {
            try{
                Restart-Computer -ComputerName $computername -ErrorAction Stop
            }
            catch {Write-Error "Unable to restart computer: $computername"}
        }
        else {
        Write-Verbose "Please restart computer: '$computername' when available."
        }
    }
}
    