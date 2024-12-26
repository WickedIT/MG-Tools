function New-CADUser {
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
Passes details from the source user account like the Path, Title, Email and Department to directly place them into the new users info.

.PARAMETER Groups
Passes specific groups to be added to the new user that are outside the scope of the Sourceuser.

.EXAMPLE
Will prompt each mandatory parameter (which is all except Groups).

PS> New-CADUser

.EXAMPLE
Add multiple users from a CSV with all mandatory parameters included.

PS> Import-CSV .\users.csv | foreach-object {New-CADUser}


#>
    param(
        [Parameter(
                Mandatory=$True,
                ValueFromPipelinebyPropertyName=$True
        )]
        [string]$FirstName,
        [Parameter(
                Mandatory=$True,
                ValueFromPipelinebyPropertyName=$True
        )]
        [string]$LastName,
        [Parameter(
                Mandatory=$True,
                ValueFromPipelinebyPropertyName=$True
        )]
        [string]$SourceUser,
        [Parameter(
                Mandatory=$False,
                ValueFromPipelinebyPropertyName=$True
        )]
        [array]$Groups
    )
        try {
                $passwd         = Invoke-RandomPassword -Length 10
                $sec_passwd     = $passwd | ConvertTo-SecureString -AsPlainText -Force #Converts the pw to a securestring
                #
                $SourceUserInfo = Get-ADUser -Identity $SourceUser -Properties Title,Department,Emailaddress #Applies the SourceUserInfo to progagate the Title, Department, and Path.
                #
                $SourceDistinguishedName = (($SourceUserInfo.Distinguishedname).split(',')) #Calls the DistinguishedName of the SourceUser to a variable and splits each section into objects
                #
                $First, $Rest = $SourceDistinguishedName #assigns the CN entry to the first variable and assigns the rest to the rest variable
                #
                $Path = $Rest -join ',' #loads the remaining objects and rejoins them to use as a path for the new user
                #
                $username = $FirstName[0] + $LastName #Joins the first letter of firstname and lastname
                #

                $userparam = @{
                        Name            = $username
                        SamAccountName  = $username
                        GivenName       = $FirstName
                        Surname         = $LastName
                        Title           = $SourceUserInfo.Title
                        Department      = $SourceUserInfo.Department
                        Path            = $Path
                        Email           = "$($username)@$($SourceUserinfo.Emailaddress.split('@')[1])"
                        AccountPassword = $sec_passwd
                        Enabled         = $true
                }
                #
                $NewUser = New-ADUser @userParam -ErrorAction Stop #Actual use of New-ADUser with all parameters
                Write-Host "Created user account for '$username'"
                $Sourceusergroups = Get-ADPrincipalGroupMembership -Identity $SourceUser | Select-Object -ExpandProperty SamAccountName | Where-Object -FilterScript {"$_ -notlike 'Domain Users'"} #Creates a joined string of all of the groups the SourceUser is a member of.
                foreach ($sourceusergroup in $sourceusergroups) {
                        try {
                                Add-ADPrincipalGroupMembership -Identity $username -MemberOf $_ -ErrorAction Continue
                                Write-Verbose "Group '$Sourceusergroup' added to user '$username' from the source user '$sourceuser'."
                        } #adds groups from the source user
                        catch {
                                Write-Error "Unable to add group '$sourceusergroup' to user '$username' from source user '$sourceuser'. : $_"
                        }
                }
                foreach ($group in $groups) {
                        try {
                                Add-ADPrincipalGroupMembership -Identity $username -MemberOf $Group -ErrorAction Continue #allows for seperatre groups to be added
                                Write-Verbose "Group '$group' added to user '$username'."
                        }
                        catch {
                                Write-Error "Unable to add group '$group' to user '$username'. : $_"
                        }
                }
        }
        catch {
                Write-Error "Unable to create user account for '$username'. : $_"
        }
        finally {
                Write-Output $NewUser # writes the output of the user properties
                Write-Output $passwd
        }
}