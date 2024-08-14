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


function Remove-WinUser {
    <#
    .SYNOPSIS
        Displays list of all user profiles and prompt for which profile to remove.
    .DESCRIPTION
        Pull's full list of User Profiles on the computer in a list, then waits for user to input which user they want to remove from the computer. Then confirms the selection.
    #>
        [CMDletBinding(SupportsShouldProcess)]
        param($VerbosePerference = "Continue")
        BEGIN{
            $UserProfiles = Get-CimInstance -ClassName Win32_UserProfile
        $UserProfileNames = foreach ($user in $userprofiles) {
                                [PSCustomObject]@{Name = $user.LocalPath.split('\')[-1]}
                            }
        $UserProfileNames | Out-Host
            
        }
        PROCESS{
            $UserInput = Read-Host "Please Select a Profile to be removed, wildcard input not aloud."
            $selection = $UserProfiles | Where-Object{$_.LocalPath -like "C:\Users\$UserInput"}
            $selectedName = $selection.LocalPath.split('\')[-1]
            Write-Verbose "Removing UserProfile $selectedName ..."
        }
        END{
            if ($null -ne $selection) {
                $selection | Remove-CimInstance -Confirm
            }
            else{
                Write-Verbose "No match found. Please try again."
            }
        }
    }
    Export-ModuleMember -function Remove-WinUser
    
    
    
    