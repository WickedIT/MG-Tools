#make script deployable with only a username needed and prompted with a list of current user accounts on the PC
function remove-customuser {
        Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.Localpath.split('\')[-1] -eq '###' } | Remove-CimInstance
    } remove-customuser