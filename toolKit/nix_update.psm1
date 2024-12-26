function Update-NixDevices {
    param([Parameter(Mandatory=$True)][System.IO.FileInfo]$path)
    $devices = Import-Csv -path $path

    foreach ($pair in $devices) {
        Write-Host "Updating $pair..." -ForegroundColor Yellow -BackgroundColor Blue
        ssh $pair "sudo apt update -y && sudo apt upgrade -y"
    }
}



#Write-Host "" -ForegroundColor Yellow -BackgroundColor Blue