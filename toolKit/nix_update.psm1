function Update-NixDevices {
    param([Parameter(Mandatory=$True)][System.IO.FileInfo]$path)
<<<<<<< Updated upstream
    $devices = Import-Csv -path $path

=======
    $devices = Get-Content -path $path
>>>>>>> Stashed changes
    foreach ($pair in $devices) {
        Write-Host "Updating $pair..." -ForegroundColor Yellow -BackgroundColor Blue
        ssh $pair "sudo apt update -y && sudo apt upgrade -y"
    }
}
<<<<<<< Updated upstream
=======
#>
<#
    try{    
        foreach ($pair in $devices) {
            if (Invoke-Polling -Device $pair.Computername -SSH) {
                New-Pssh -username $pair.Username -computername $pair.Computername -Command "sudo apt update -y" -ErrorAction Continue
                Write-Host "Updating $($pair.Computername).." -ForegroundColor Yellow -BackgroundColor Blue
            }
            else {
                throw "$($pair.Computername) not online."
            }
        }
    }
    catch {
        Write-Error "There was an issue updating the hosts : $"_
    }
#>

>>>>>>> Stashed changes



#Write-Host "" -ForegroundColor Yellow -BackgroundColor Blue