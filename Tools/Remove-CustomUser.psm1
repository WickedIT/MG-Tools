#make script deployable with only a username needed and prompted with a list of current user accounts on the PC
function remove-customlocaluser {
    param([Paramter(Mandatory=$False)][string]$Identity)
    BEGIN{
        $localUsers = Get-Localusers
        Out-Host $localUsers
        


    }
    PROCESS{ 
        Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.Localpath.split('\')[-1] -eq '###' } | Remove-CimInstance
    }
    END{

    }
} 
New-Alias rclu Remove-CustomLocalUser
Export-ModuleMember -function Remove-CustomLocalUser
Export-ModuleMember -Alias rclu


