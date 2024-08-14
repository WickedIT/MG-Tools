function Disable-USBPowerManagment {
<#
.SYNOPSIS
	Sets all USB Hub power_management options to $false
.DESCRIPTION
	Uses Get-CimInstance to find all Devices with Power_Management settings; then disables it. This does not affect K/M to wake device (the PC is already incapable of turning those off but the option to wake remains). This function is minimally invasive because the classname is designed such that the only real change it is capable of making is that specific setting where it is applied.
#>
    $USBPowerHubs = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable #Grabs USB Hubs.
    foreach ($hub in $USBPowerHubs) {#Feeds each hub through Set-CimInstance to set the property to $false.
        $hub | Set-CimInstance -Property @{Enable=$false}
        Write-Host $hub
    }
}
#Export-ModuleMember -Function Disable-USBPowerManagment

