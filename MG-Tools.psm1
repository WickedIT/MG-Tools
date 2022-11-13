<#
Random password generator.
############################################################################
#>

function Call-RandomPassword {
<#
.SYNOPSIS
Calls random Secure String password of 72 normal characters at any length noted by the length parameter.

.DESCRIPTION
Injects 72 characters to the Get-Random CMDlet to produce a string, then converts the string to a secure string. Once converted, the Password is displayed on the host and copied to the clipboard.

.PARAMETER Length
Use an length you see fit, no restriction is in place for length.

.EXAMPLE
PS>Call-RandomPassword -Count 10

#>
    param(
        [Parameter(Mandatory=$True)]
        $Length
    )
    [array]$characters = 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
                  '1','2','3','4','5','6','7','8','9','0',
                  'A','B','C','D','E','F','G','H','J','I','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                  '!','@','#','$','%','^','&','*','(',')'
    $pw = ($characters | Get-Random -count $Length) -join ''
    $pw
    $pw | clip
}

New-Alias rpw Call-RandomPassword
Export-ModuleMember -Function Call-RandomPassword
Export-ModuleMember -Alias rpw
<#
###########################################################################
#>

<#
Advanced function to create new user in Active Directory.
###########################################################################
#>

function Call-NewADUser {
<#
.SYNOPSIS
Calls an advanced function to streamline New-ADUser creation by individual user or multiple users.

.DESCRIPTION
This CMDlet is designed to prompt for each required parameter field dictated by the Domain Admin. It is also designed to take input by csv. 
It also adds the parameter 'Groups' and 'SourceUser' which will allow you to copy the memberships from a Source User, or add a specific Group(s). The password for the account is supplied by a random password generator and is shown in the console and copied to the clipboard.

.PARAMETER FirstName
Passes the Firstname to Given Name, Name, and SamAccountName

.PARAMETER LastName
Passes LastName to Surname, Name, and SamAccountName

.PARAMETER SourceUser
Passes details from the source user account like the Path, Title, and Department to directly place them into the new users info.

.PARAMETER Groups
Passes specific groups to be added to the new user that are outside the scope of the Sourceuser.

.EXAMPLE
Will prompt each mandatory parameter (which is all except Groups).

PS> Call-NewAduser

.EXAMPLE
Add multiple users from a CSV with all mandatory parameters included.

PS> Import-CSV .\users.csv | Call-NewADUser


#>
    [CMDletBinding(SupportsShouldProcess)]
    param(
        $VerbosePreference = "Continue",
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$FirstName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$LastName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$SourceUser,
        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [array]$Groups
    )
    BEGIN {
    }

    PROCESS {
        if ($null -ne $_) {
            foreach ($user in $_){
                $pw = Call-RandomPassword -Length 10 #Calls password thats 10 characters long
                $spw = ConvertTo-SecureString $pw -AsPlainText -Force #Converts the pw to a securestring
                $SourceUserInfo = Get-ADUser -Identity $user.SourceUser -Properties Title,Department | select samaccountname, Distinguishedname, Title, Department #Applies the SourceUserInfo to progagate the Title, Department, and Path.
                $title = $SourceUserInfo.Title
                $department = $SourceUserInfo.Department
                $SourceDistinguishedName = (($SourceUserInfo.Distinguishedname).split(',')) #Calls the DistinguishedName of the SourceUser to a variable and splits each section into objects
                $First, $Rest = $SourceDistinguishedName #assigns the CN entry to the first variable and assigns the rest to the rest variable
                $Path = $Rest -join ',' #loads the remaining objects and rejoins them to use as a path for the new user
                $FirstLast = $user.FirstName[0] + $user.LastName #Joins the first letter of firstname and lastname
                $email = "$($FirstLast)@mfgwickedit.onmicrosoft.com" #Creates the email entry.
                $sourceusergroups = Get-ADPrincipalGroupMembership -Identity $SourceUserInfo.SamAccountName | select -ExpandProperty samaccountname #Creates a joined string of all of the groups the SourceUser is a member of.
                #
                New-ADUser -Name $FirstLast -SamAccountName $FirstLast -GivenName $user.FirstName -Surname $user.LastName -Title $title -Department $department -Path $path -EmailAddress $email -AccountPassword $spw -Enabled $true #Actual use of New-ADUser with all parameters and variables
                #
                $properties = [ordered]@{Name=$user.FirstName + ' ' + $user.LastName #Display a list of user properties.
                                         Title=$title
                                         Department=$department
                                         Password=$pw
                                         Email=$email
                                         Groups=($sourceusergroups) -Join ', '
                                         SourceUser=$user.SourceUser
                }
                $obj = New-Object -TypeName psobject -Property $properties #Passes properties to variable
                if ($user.groups -ne $null) { #checks for values in groups# 
                    foreach ($group in $groups) {
                        Add-ADGroupMember -Identity $group -Members $FirstLast -ErrorAction SilentlyContinue #allows for seperatre groups to be added
                    }
                }
                elseif ($user.SourceUser -ne $null) {  #checks for value in Sourceuser#
                    foreach ($sourceusergroup in $sourceusergroups) {
                        Add-ADGroupMember -Identity $sourceusergroup -Members $FirstLast -ErrorAction SilentlyContinue #adds groups from the source user
                    }
                }
                Write-Output $obj # writes the output of the user properties
            }
        }
        else {
            $pw = Call-RandomPassword -Length 10 #Calls password thats 10 characters long
            $spw = ConvertTo-SecureString $pw -AsPlainText -Force #Converts the pw to a securestring
            $SourceUserInfo = Get-ADUser -Identity $SourceUser -Properties Title,Department | select samaccountname, Distinguishedname, Title, Department #Applies the SourceUserInfo to progagate the Title, Department, and Path.
            $title = $SourceUserInfo.Title
            $department = $SourceUserInfo.Department
            $SourceDistinguishedName = (($SourceUserInfo.Distinguishedname).split(',')) #Calls the DistinguishedName of the SourceUser to a variable and splits each section into objects
            $First, $Rest = $SourceDistinguishedName #assigns the CN entry to the first variable and assigns the rest to the rest variable
            $Path = $Rest -join ',' #loads the remaining objects and rejoins them to use as a path for the new user
            $FirstLast = $FirstName[0] + $LastName #Joins the first letter of firstname and lastname
            $email = "$($FirstLast)@mfgwickedit.onmicrosoft.com" #Creates the email entry.
            $sourceusergroups = Get-ADPrincipalGroupMembership -Identity $SourceUserInfo.SamAccountName | select -ExpandProperty samaccountname #Creates a joined string of all of the groups the SourceUser is a member of.
            #
            New-ADUser -Name $FirstLast -SamAccountName $FirstLast -GivenName $FirstName -Surname $LastName -Title $title -Department $department -Path $path -EmailAddress $email -AccountPassword $spw -Enabled $true #Actual use of New-ADUser with all parameters and variables
            #
            $properties = [ordered]@{Name=$FirstName + ' ' + $LastName #Display a list of user properties.
                                     Title=$title
                                     Department=$department
                                     Password=$pw
                                     Email=$email
                                     Groups=($sourceusergroups) -Join ', '
                                     SourceUser=$SourceUser
            }
            $obj = New-Object -TypeName psobject -Property $properties #Passes properties to variable
            if ($user.groups -ne $null) { #checks for values in groups# 
                foreach ($group in $groups) {
                    Add-ADGroupMember -Identity $group -Members $FirstLast -ErrorAction SilentlyContinue #allows for seperatre groups to be added
                }
            }
            elseif ($user.SourceUser -ne $null) {  #checks for value in Sourceuser#
                foreach ($sourceusergroup in $sourceusergroups) {
                    Add-ADGroupMember -Identity $sourceusergroup -Members $FirstLast -ErrorAction SilentlyContinue #adds groups from the source user
                }
            }
            Write-Output $obj # writes the output of the user properties

    }
}
    END {
        $pw | clip #passes the password to the clipboard
    }
}
New-Alias nadu Call-NewADUser
Export-ModuleMember -Function Call-NewADUser
Export-ModuleMember -Alias nadu
<#
###########################################################################
#>
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
        Get-ItemProperty @CurrentItemSet | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue #Pushes the StateFlag001 switch to be removed from every subpath in VolumeCaches if it exists

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


function WorkDriveCleanUp {
    param(
        $VerbosePreference = 'Continue',
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        $computername
    )
    BEGIN {
        $lastboot = Get-CimInstance -ClassName Win32_OperatingSystem | select -ExpandProperty LastBootUpTime #grabs time since last boot
        $currentdate = Get-Date
        $continue = $false
        $restart = $false
        if (($currentdate - $lastboot | select -ExpandProperty 'Days') -eq '0') { #checks to see if Lastbootuptime is less than 1 day
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
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computername -Filter "DeviceID='C:'" #get primary disk info
   [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int] #take disk info and form it into percentage
        if ($continue) {  #if lastboot is = 0 then run disk cleanup
            if ($percentavail -in 11..80) { #if the integer of percentleft fits into range, run clean
                #Run Disk Cleanup
                Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden #/sagerun:1 runs the StateFlags001 switches
                Write-Verbose "Drive Percent Left is: '$percentavail', make necessary changes to Disk Clean Tool options."
            }
            elseif ($percentavail -in 0..10) { #if the integer of percentleft fits into this range as well, prompt for further discovery
                $computername | Out-File Comp_Drive_Full.txt -Append
                Write-Verbose "Check the Comp_Drive_Full text file."
            }
            
        }
    }
    END {
    }
}

function Call-DriveCleanUp {
<#
.SYNOPSIS
Automates minor disk cleanup.

.DESCRIPTION
This CMDlet collects information about "C" drive of a computer local or otherwise. This includes objects passed through the pipeline. After collecting the information the CMDlet determines whether the computer needs to be restarted, trimmed, or if it needs further attention.

.PARAMETER computername
Specifies the computername variable. No default value but 'localhost' is accepted.

.EXAMPLE
PS> Call-DriveCleanup -computername 'localhost'

.EXAMPLE
PS> Get-ADComputer -filter "name -like '*'" | Call-DriveCleanUp

#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True
    )]
    [Alias("Name")]
    $computername
    )
    BEGIN {
        $credential = Get-Credential -Message "If not Q'ing AD computers, ignore credential request." #get credential or ignore if localhost
        del .\Comp_No_Connection.txt -ea SilentlyContinue
        del .\Comp_Drive_Full.txt -ea SilentlyContinue
        
    }
    PROCESS {
        $currentdate = Get-Date
        if ($computername -ne 'localhost') { #if querying several computers, try running sessions
            foreach ($computer in $computername) {
                if ((Test-NetConnection -ComputerName $Computer -CommonTCPPort WinRM).TcpTestSucceeded) {#test TCP connection
                    $session = New-PSSession -ComputerName $computer -Credential $credential -ea SilentlyContinue #new pssession
                    $cimsession = New-CimSession -ComputerName $computer -Credential $credential -ea SilentlyContinue #new cimsession
                    $lastboot = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cimsession | select -ExpandProperty LastBootUpTime | select Days,Hours,Minutes #grap last boot up time
                    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $cimsession -Filter "DeviceID='C:'" #grab primary disk info
                    [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int] #convert disk available to percentage
                    $properties = [Ordered]@{Computername = "$computer"
                                             Status = "Connected"
                                             DriveAvail = "% $percentavail"
                                             Uptime = "$lastboot"
                                             }
                } #display computer info in an object
                else {
                    $computer | Out-File Comp_No_Connection.txt -Append
                    $properties = [Ordered]@{Computername = "$computer"
                                                   Status = "Disconnected"
                                             }
                } #display alternate computer info for failed computers
                    $obj = New-Object -TypeName psobject -Property $properties
                    Write-Output $obj
                    Invoke-Command -Session $session -ScriptBlock ${function:Set-DriveCleanupOptions} #preps the sagerun switches with invoke-command
                    Invoke-Command -Session $session -ScriptBlock ${function:WorkDriveCleanUp} -ArgumentList $Computer #runs the function for disk cleanup with invoke-command
            }
        }
        else { #if running against localhost, output and function is essentially the same just shortened           
            $lastboot = Get-CimInstance -ClassName Win32_OperatingSystem | select -ExpandProperty LastBootUpTime | select Days,Hours,Minutes
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
            [int]$percentavail = ($disks.Freespace / $disks.Size) * 100 -as [int]
            $properties = [Ordered]@{Computername = "$computername"
                                     Status = "Connected"
                                     DriveAvail = "% $percentavail"
                                     Uptime = "$lastboot"
                                     }
            $obj = New-Object -TypeName psobject -Property $properties
            Set-DriveCleanupOptions
            WorkDriveCleanUp -computername $computername
            Write-Output $obj
        }
    }
    END {
      
    }
    
}
<#
###########################################################################
#>

New-Alias cleanup Call-DriveCleanUp
Export-ModuleMember -Function Call-DriveCleanUp
Export-ModuleMember -Alias cleanup



