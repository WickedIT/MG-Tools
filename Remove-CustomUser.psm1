function remove-customuser {
        Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.Localpath.split('\')[-1] -eq '###' } | Remove-CimInstance
    } remove-customuser