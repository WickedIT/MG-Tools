function remove-customuser {
        Get-CimInstance -Class Win32_UserProfile | where { $_.Localpath.split('\')[-1] -eq '###' } | Remove-CimInstance
    } remove-customuser