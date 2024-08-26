function Get-OUDetails {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $VerbosePreference = "Continue"

    )
    BEGIN {
        $computers = $comp_list 
    }
    PROCESS {    
        foreach ($comp in $computers) {
            try{
                $CompProperties = @{
                    Identity    = "$comp"
                    Properties  = "Description","LastLogonDate"
                    ErrorAction = "Stop"
                    }
                $ComputerInfo = Get-ADComputer @CompProperties
            }
            catch {
                Write-Verbose "$Comp not in AD"
            }
            if ($null -ne $ComputerInfo.Description ) {
                $DN             = $ComputerInfo.DistinguishedName.split(',')
                $OU             = $DN[2].split('=')[1]
        [string]$Description    = $ComputerInfo.Description
                $LastLogon      = $ComputerInfo.LastLogonDate
                $Branch         = $Description.split('-')
                $File           = $Branch[0].TrimEnd()
                $Display        =[PSCustomObject]@{
                                    Name        = "$comp"
                                    OU          = "$OU"
                                    LastLogon   = "$LastLogon"
                                    Place       = "$Description"
                                }
                Write-OutPut $Display |
                    format-list |
                        Out-File `
                            -FilePath  `
                            -append
            }
        }

    }
    END {
    }
}
#Get-OuDetails