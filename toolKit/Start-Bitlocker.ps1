function Start-Bitlocker {
<#
.SYNOPSIS
	Grabs TPM info and tries to start bitlocker encryption if the TPM is available, not ready, and/or not activated.
.DESCRIPTION
	Uses TPM info to check the following: 
		BEGIN:(if tpm not owned or ready; initialize tpm.), 
		BEGIN:(if tpm already owned and ready; pipe info to txt and end script.),
		BEGIN:(rename reagent.xml to fix bitlocker issue.), 
		PROCESS:(if tpm owned and ready now; turn on bitlocker. If not, pipes relevant error to txt.),
		END:(if bitlocker-start outputs EXACT desired report and the key-word matches in the EXACT desired location of the report; restart device. if not pipe to txt.)

#>
#BEGIN: Grabs TPM info, then runs through conditionals for making sure tpm is not activated and not ready. If both apply, initialize-tpm. If tpm activated, pipe tpm info to txt file. Rename reagent.xml to solve bitlocker issue.
    BEGIN {
        $Date = Get-Date
        Start-Transcript "C:\$Date"
		$continue = $true
        $TPMStatus = Get-Tpm
        $TPMStatus | Write-Output
		if (($TPMStatus.TPMOwned -eq $false) -or ($TPMStatus.Ready -eq $false)) {
				$InitTPM = Initialize-TPM
		}
		else {
			$TPMStatus | Write-OutPut | Out-File c:\TPMIssue.txt -Append
        }
		Rename-Item -Path "C:\Windows\System32\Recovery\ReAgent.xml" -NewName ReAgent.old
    }
#PROCESS: Runs more conditionals to make sure initialize worked, then turns on bitlocker. With Out-File entries in case it didnt work.
    PROCESS{
        $TPMStatus = Get-Tpm
        $TPMStatus | Write-Output
		if ($TPMStatus.TPMOwned) {
			if ($InitTPM.TPMReady) {
				$bitlockeron = manage-bde -on c:
			}
			else {
				Write-Output "TPM is not ready." | Out-File c:\TPMIssue.txt -Append
			}
		}
		else {
			Write-Output "TPM is not owned." | Out-File c:\TPMIssue.txt -Append
		}
    }
#END: Uses the info from starting Bitlocker to match the desired report EXACTLY before pushing a reboot to start encrypting. If the report does not match the required value, the info is instead piped to a file.
    END {
        if ($bitlockeron[14].split('.')[1].split(' ')[1] -match 'Restart') {
            Shutdown /r
        }
        else {
            $bitlockeron | Write-Output | out-file C:\BitLockerError.txt
            Stop-Transcript
        }

    }
}
Start-Bitlocker

<#
.SIGNATURE
	Michael Gagnon (IT Support Technician)
	
.DATE
	January 17th, 2023
#>