function Invoke-AudioDevSwap {
$module = 'AudioDeviceCmdlets'
    if (!(Get-Module -Name $module -ListAvailable)) {
        Install-Module -name $module -Force -Verbose
    }
    if (!(Get-Module -name $module)) {
        Import-Module -name $module -Force
    }
    
    $AudioDevOne        = "{0.0.0.00000000}.{46ab9fd8-3c7a-4624-bf81-d42042e71ee6}"
    $AudioDevTwo        = "{0.0.0.00000000}.{658c84cb-563a-43d6-ba2d-1b8fedc417eb}"
    $currentPlayback    = Get-AudioDevice -Playback

    if ($currentPlayback.ID -eq $AudioDevOne) {
        try{
            $newPlayback   = Set-AudioDevice -ID $AudioDevTwo -ErrorAction Stop
            $wshell        = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Playback Device set to: $($newPlayback.Name)")
            
        }
        catch {
            Write-Error "Device not set. Current playback is still '$($currentPlayback.name)'"
            break
        }
    }
    else{
        try{
            $newPlayback   = Set-AudioDevice -ID $AudioDevOne -ErrorAction Stop
            $wshell     = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Playback Device set to: $($newPlayback.Name)")
            
        }
        catch {
            Write-Error "Device not set. Current playback is still '$($currentPlayback.name)'"
            break
        }
    }
}
Invoke-AudioDevSwap