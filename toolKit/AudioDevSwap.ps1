function Invoke-AudioDevSwap {
    $module = 'AudioDeviceCmdlets'
    if (!(Get-Module -Name $module -ListAvailable)) {#Checks that module is installed, installs if not.
        try {
            Install-Module -name $module -Force -Verbose -ErrorAction Stop
        }
        catch {
            Write-Error "Unable to install the '$module' module from PSGallery."
            break
        }
    }
    if (!(Get-Module -name $module)) {#Checks that $module is loaded, loads and continues if not.
        try {
            Import-Module -name $module -Force -ErrorAction Stop
        }
        catch {
            Write-Error "Unable to import module. Check that it installed correctly."
            break
        }
    }

    if (Get-module -Name AudioDeviceCmdlets) {#Tests for AudioDeviceCmdlets.
        if ( ! (Test-Path -Path .\swap_devices.txt)) {#Test for list of devices to swap to, creates and fills file if not.
            try {
                $swapDevices = New-Item -Name swap_devices.txt -ErrorAction Stop
            }
            catch {
                Write-Error "Something went wrong : $swapDevices"
                break
            }
            $devices= Get-AudioDevice -list | Select-Object -Property Name,ID
            foreach ($device in $devices) {#Iterate through devices and print to host.
                Write-Host "ID='$($device.ID)';Name='$($device.Name)'"
            }
            Write-Host "Please input the 2 devices to switch between. (Hint copy/paste)"
            $audioDevOne = Read-host "Audio Device One " | Out-File $swapDevices -Append
            $audioDevTwo = Read-Host "Audio Device Two " | Out-File $swapDevices -Append
        }
        else {#Sources swap_devices.txt for devices and loads to variables.
            try {
                $swapDevices = Get-Item swap_devices.txt -ErrorAction Stop
            }
            catch {
                Write-Error "Something went wrong : $swapDevices"
                break
            }
            $audioDevOne = (Get-Content $swapDevices)[0]
            $audioDevTwo = (Get-Content $swapDevices)[1]
        }
        $currentPlayback = Get-AudioDevice -Playback
        if ($currentPlayback.ID -eq $audioDevOne) {#Check if playback device is set to Dev#1 | switches to Dev#2
            try{
                $newPlayback= Set-AudioDevice -ID $audioDevTwo -ErrorAction Stop
                $wshell= New-Object -ComObject Wscript.Shell
                $wshell.Popup("Playback Device set to: $($newPlayback.Name)")
                
            }
            catch {
                Write-Error "Device not set. Current playback is still '$($currentPlayback.name)'"
                break
            }
        }
        else{#If playback was Dev#2 | switches to Dev#1
            try{
                $newPlayback = Set-AudioDevice -ID $audioDevOne -ErrorAction Stop
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup("Playback Device set to: $($newPlayback.Name)")
                
            }
            catch {
                Write-Error "Device not set. Current playback is still '$($currentPlayback.name)'"
                break
            }
        }
    }
}
Invoke-AudioDevSwap