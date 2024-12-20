function Update-NixDevices {
    param([Parameter(Mandatory=$True)][System.IO.FileInfo]$path)
    $devices = Import-Csv -path $path
<#
    foreach ($pair in $devices) {
        Write-Host "Updating $pair..." -ForegroundColor Yellow -BackgroundColor Blue
        ssh $pair "sudo apt update -y && sudo apt upgrade -y"
    }
}
#>

    [System.Management.Automation.PSRemotingJob]$jobs = $null
    try{    
        foreach ($pair in $devices) {
            try {
                if (Invoke-Polling -Device $pair.Computername -SSH) {
                    $jobs = Start-Job -name $pair.Computername -ScriptBlock {
                        function:New-Pssh -username $($using:pair).Username -computername $($using:pair).Computername -Command "ls"} -ErrorAction Continue
                    Write-Host "Updating $pair.." -ForegroundColor Yellow -BackgroundColor Blue
                }
                else {
                    throw "$pair not online."
                }
            }
            catch {
                Write-Error "Unable to update $pair : $_"
            }
        }
    }
    catch {
        $_
    }
    finally {
        if ($null -ne $jobs) {
            $clean += while ($jobs.Count -gt 0) {
                foreach ($job in $jobs) {
                    if ($job.State -eq 'Completed') {
                        Write-Host "'Job $($job.Name)' has completed, here are the results." -ForegroundColor Yellow -BackgroundColor Blue
                        Receive-Job -id $job.id
                        Remove-Job -id $job.Id
                        $jobs = $jobs | Where-Object -Property Id -NE $job.Id
                    }
                    elseif ($job.State -match "Failed|Stopped") {
                        Write-Warning "Job $($Job.Name) has failed or was stopped."
                        Remove-Job -id $job.Id
                        $jobs = $jobs | Where-Object -Property Id -NE $job.Id
                    }
                    else {
                        Start-Sleep -Seconds 1
                    }
                }
            }
        }
    }
}




#Write-Host "" -ForegroundColor Yellow -BackgroundColor Blue