function Invoke-WUStatus {
    param($computername)
    $session = New-PSSession -ComputerName $computername
    try{
        Invoke-Command -Session $session -scriptblock {(Get-wsusserver).GetSubscription().GetLastSynchronizationInfo()} -ErrorAction Stop
    }
    catch {
        Write-Output "Something went wrong, this is the device entered: "$($computername)". Please try again with another computer or debug."
    }
    
}
Export-ModuleMember -Function Invoke-WUStatus