function Invoke-UpdateHealth {
    <#
    Collect available updates from each Windows device to ensure nothing is hanging.
    #> 
    }


    function Invoke-WUStatus {
        param($computername='vm-updates')
        $session = New-PSSession -ComputerName $computername
        try{
            Invoke-Command -Session $session -scriptblock {(Get-wsusserver).GetSubscription().GetLastSynchronizationInfo()} -ErrorAction Stop
        }
        catch {
            Write-Output "Sometihng went wrong, this is the device entered: "$($computername)". Please try again with another computer or debug."
        }
        
    }
    Export-ModuleMember -Function Invoke-WUStatus