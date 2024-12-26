#Requires -Modules AudioDeviceCmdlets
function Set-PlaybackDevice {
    param (
        [Parameter(Mandatory,Position=0)][string]$DeviceOne,
        [Parameter(Mandatory,Position=1)][string]$DeviceTwo
    )
    $commDevs = Get-AudioDevice -list | where-object {($_.Type -eq "Playback") -and (($_.name -like "*$DeviceOne*") -or ($_.name -like "*$DeviceTwo*"))}
    $playback = Get-AudioDevice -playback
    if ($commDevs[0].ID -eq $playback.ID) {
        Set-AudioDevice -ID $commDevs[1].ID
    }
    else {
        Set-AudioDevice -ID $commDevs[0].ID
    }
}