#I dont think this will be useful henceforth but I think it will be good to keep as a template later.

function Update-WinCred {
    param($VerbosePreference='Continue')
    
    BEGIN {
        $ComputerList = Get-ADComputer `
                        -Filter "name -like 'PC*'" |
                            Select-Object `
                                -ExpandProperty Name
        $Credential = Get-Credential
        $CredList = Get-StoredCredential `
                        -Type DomainPassword `
                        -AsCredentialObject
        $Targets = $CredList.Targetname | Where-Object {$_ -like '*PC*'}
    }
    PROCESS{
        foreach ($name in $ComputerList) {
            if ($Targets -notcontains "Domain:target=$name") {
                New-StoredCredential `
                    -Target $name `
                    -Credentials $Credential `
                    -Type DomainPassword `
                    -Persist LocalMachine
                Write-Verbose "Credential for '$name' was created."
            }
        }
    }
    END {
        foreach ($Target in $Targets) {
            $pcname = $Target.split('=')
            if ($ComputerList -notcontains $pcname[1]) {
                $device = $pcname[1]
                $device | Out-File RemovedCredentials.txt -Append
                Write-Verbose "Credential for $device was not found in AD and was to be removed from credentials."
            }
        }
        $PCCount = ($ComputerList | Measure-Object).Count
        Write-Verbose "There are '$PCCount' computers in AD."

    }
}
Update-WinCred
notepad.exe .\RemoveCredentials.txt

