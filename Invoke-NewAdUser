function Invoke-NewADUser {
<#
.SYNOPSIS
Calls an advanced function to streamline New-ADUser creation by individual user or multiple users.

.DESCRIPTION
This CMDlet is designed to prompt for each required parameter field dictated by the Domain Admin. It is also designed to take input by csv. 
It also adds the parameter 'Groups' and 'SourceUser' which will allow you to copy the memberships from a Source User, or add a specific Group(s). The password for the account is supplied by a random password generator and is shown in the console and copied to the clipboard.

.PARAMETER FirstName
Passes the Firstname to Given Name, Name, and SamAccountName

.PARAMETER LastName
Passes LastName to Surname, Name, and SamAccountName

.PARAMETER SourceUser
Passes details from the source user account like the Path, Title, and Department to directly place them into the new users info.

.PARAMETER Groups
Passes specific groups to be added to the new user that are outside the scope of the Sourceuser.

.EXAMPLE
Will prompt each mandatory parameter (which is all except Groups).

PS> Call-NewAduser

.EXAMPLE
Add multiple users from a CSV with all mandatory parameters included.

PS> Import-CSV .\users.csv | foreach-object {Call-NewADUser}


#>
    [CMDletBinding(SupportsShouldProcess)]
    param(
        $VerbosePreference = "Continue",
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$FirstName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$LastName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [string]$SourceUser,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True
        )]
        [array]$Groups
    )
    BEGIN {
    }

    PROCESS {
        $pw = Invoke-RandomPassword `
                -Length 10 #Calls password thats 10 characters long
        #
        $spw = ConvertTo-SecureString $pw `
                -AsPlainText `
                -Force #Converts the pw to a securestring
        #
        $SourceUserInfo = Get-ADUser `
                -Identity $SourceUser `
                -Properties Title,Department #Applies the SourceUserInfo to progagate the Title, Department, and Path.
        #
        $SourceDistinguishedName = (($SourceUserInfo.Distinguishedname).split(',')) #Calls the DistinguishedName of the SourceUser to a variable and splits each section into objects
        #
        $First, $Rest = $SourceDistinguishedName #assigns the CN entry to the first variable and assigns the rest to the rest variable
        #
        $Path = $Rest -join ',' #loads the remaining objects and rejoins them to use as a path for the new user
        #
        $FirstLast = $FirstName[0] + $LastName #Joins the first letter of firstname and lastname
        #
        $Sourceusergroups = Get-ADPrincipalGroupMembership `
                                -Identity $SourceUser |
                                        Select-Object `
                                                -ExpandProperty SamAccountName #Creates a joined string of all of the groups the SourceUser is a member of.
        $userparam = @{
                Name            = $FirstLast
                SamAccountName  = $FirstLast
                GivenName       = $FirstName
                Surname         = $LastName
                Title           = $SourceUserInfo.Title
                Department      = $SourceUserInfo.Department
                Path            = $Path
                Email           = "$($FirstLast)@mfgwickedit.onmicrosoft.com"
                AccountPassword = $spw
                Enabled         = $true
        }
        #
        New-ADUser @userParam #Actual use of New-ADUser with all parameters
        #
        $properties = [ordered]@{
                Name        = $FirstName + ' ' + $LastName #Display a list of user properties.
                Title       = $SourceUserInfo.Title
                Department  = $SourceUserInfo.Department
                Password    = $pw
                Email       = $email
                Groups      = (($sourceusergroups) + ($groups)) -Join ', '
                SourceUser  = $SourceUser
        }
        #
        $obj = New-Object `
                    -TypeName psobject `
                    -Property $properties #Passes properties to variable
        #
    }
    END {
        if ($Groups -ne $null) { #checks for values in groups# 
                Add-ADPrincipalGroupMembership `
                     -Identity $FirstLast `
                     -MemberOf $Groups #allows for seperatre groups to be added
            }
        #
        if ($SourceUser -ne $null) {  #checks for value in Sourceuser#
                Add-ADPrincipalGroupMembership `
                    -Identity $FirstLast `
                    -MemberOf $Sourceusergroups `
                    -ErrorAction SilentlyContinue #adds groups from the source user
        }
        #
        Write-Output $obj # writes the output of the user properties
        $pw | clip #passes the password to the clipboard
        
    }
}
    New-Alias iadu Invoke-NewADUser
    Export-ModuleMember -Function Invoke-NewADUser
    Export-ModuleMember -Alias iadu
<#
###########################################################################
#>