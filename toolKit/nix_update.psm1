function Update-NixDevices {
    param([Parameter(Mandatory=$True)][System.IO.FileInfo]$path)
    $date = Get-Date -Format "dd_MM_yyyy"
    $devices = Get-Content -path $path
    foreach ($pair in $devices) {
        Write-Host "Updating $pair..." -ForegroundColor Yellow -BackgroundColor Blue
        $content = Invoke-Command -ScriptBlock {ssh "$pair" "sudo apt update -y && sudo apt upgrade -y"} -ErrorAction SilentlyContinue | Out-Null
        $content | Out-File -Path "Z:\for_Lab\script_Outputs\+nix_updates\$($date)-$($pair.split('@')[1]).txt"
    }
}
Update-NixDevices -Path "C:\ADMIN\The_Vault\+nix_devices.txt"