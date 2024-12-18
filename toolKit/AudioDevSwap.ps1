<#function Invoke-AudioDevSwap {
    $module = 'AudioDeviceCmdlets'
    if (!(Get-Module -Name $module -ListAvailable)) {#Checks that module is installed, requests permission and installs if not.
        $continue = Read-Host "The module 'AudioDeviceCmdlet' is required but not installed, would you like to install it? (y/n)"
        if ($continue.ToLower -eq 'y') {
            try {
                Install-Module -name $module -Force -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error "Unable to install the '$module' module from PSGallery."
                return
            }
        }
        else {exit}
    }
    if (!(Get-Module -name $module)) {#Checks that $module is loaded, loads and continues if not.
        try {
            Import-Module -name $module -Force -ErrorAction Stop
        }
        catch {
            Write-Error "Unable to import $module module. Check that it installed correctly."
            return
        }
    }

    if (Get-module -Name AudioDeviceCmdlets) {#Tests for AudioDeviceCmdlets.
        if ( ! (Test-Path -Path $PSScriptRoot\swap_devices.txt)) {#Test for list of devices to swap to, creates and fills file if not.
            try {
                $swapDevices = New-Item -Path $PSScriptRoot\swap_devices.txt -ErrorAction Stop
            }
            catch {
                Write-Error "Something went wrong : Unable to create the text file for device list storage. Make sure the user running the script has permission to create files in the directory."
                return
            }
            $devices= Get-AudioDevice -list | Select-Object -Property Name
            $n=0
            foreach ($device in $devices) {#Iterate through devices and print to host.
                Write-Host "$n - '$($device.Name)'" -ForegroundColor Yellow -BackgroundColor Black
                $n+=1
            }
            Write-Host "Please input the '#' placeholder for the 2 devices to switch between. " -ForegroundColor Black -BackgroundColor Yellow
            $devOne=Read-Host "Audio Device #1 "
            $devTwo=Read-Host "Audio Device #2 "
            
            @(
                $devices[$devOne].Name
                $devices[$devTwo].Name
            ) | Set-Content -Path $swapDevices
        }
        else {#Sources swap_devices.txt for devices and loads to variables.
            try {
                $swapDevices = Get-ChildItem -Path $PSScriptRoot\swap_devices.txt -ErrorAction Stop
            }
            catch {
                Write-Error "Something went wrong : Unable to read the text file @ '$($swapDevices)'. Make sure that the script is in the same folder as the 'swapDevices.txt' file and the file contains the 2 ID's. If anything is wrong with the content, recreate the file."
                return
            }
        }
        $audioDev = Get-Content -Path $swapDevices | Select-Object -First 2
        $currentPlayback = Get-AudioDevice -Playback
        try{
            if ($currentPlayback.ID -eq $audioDev[0]) {#Check if playback device is set to Dev#1 | switches to Dev#2    $newPlayback= Set-AudioDevice -ID $audioDev[1] -ErrorAction Stop
                $newPlayback = Set-AudioDevice -ID $audioDev[1] -ErrorAction Stop
                $wshell= New-Object -ComObject Wscript.Shell
                $wshell.Popup("Playback Device set to: $($newPlayback.Name)")   
            }
            else{
                $newPlayback = Set-AudioDevice -ID $audioDev[0] -ErrorAction Stop
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup("Playback Device set to: $($newPlayback.Name)")
            }
        }
        catch {
            Write-Error "Device not set. Current playback is still '$($currentPlayback.name)'"
            return
        }
    }
}
#Invoke-AudioDevSwap
#>

function Set-PlaybackDev {
    if (! (Get-Module -name AudioDeviceCmdlets)) {
        Import-Module AudioDeviceCmdlets
    }
    $commDevs = Get-AudioDevice -list | where-object {($_.Type -eq "Playback") -and (($_.name -like "*dell*") -or ($_.name -like "*Logitech*"))}
    $playback = Get-AudioDevice -playback
    if ($commDevs[0].ID -eq $playback.ID) {
        Set-AudioDevice -ID $commDevs[1].ID
    }
    else {
        Set-AudioDevice -ID $commDevs[0].ID
    }
}
Set-PlaybackDev | Out-Null