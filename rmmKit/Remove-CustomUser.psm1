#make script deployable with only a username needed and prompted with a list of current user accounts on the PC
function remove-customlocaluser {
        $localUsers = Get-Localuser
        $n = 1
        foreach ($user in $localUsers) {
            $listOfLocalUsers += "|<< $n. $($user.name) >>|"
            $n += 1
        }
        Write-Host "This is the list of local users!"
        $listOfLocalUsers | Write-Output
        [int]$numberAssignedToLocalUser = Read-Host "Please select user to be removed by its number!"
        $actualUserIndex = $numberAssignedToLocalUser - 1
        $actualUsertoRemove = $localUsers[$actualUserIndex] | Remove-LocalUser
        Write-Output $actualUsertoRemove


} 
New-Alias rclu Remove-CustomLocalUser
Export-ModuleMember -function Remove-CustomLocalUser
Export-ModuleMember -Alias rclu


<#
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.Localpath.split('\')[-1] -eq '###' } | Remove-CimInstance
#>

