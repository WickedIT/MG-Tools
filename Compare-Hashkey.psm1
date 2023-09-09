function Compare-Hashkey {
    $download_hash = Read-Host "Please enter the downloads expected sha256."
    $exe_path = Read-Host "Please provide the EXE's download path."
    $find_exe_path = Get-ChildItem -Path "C:\Users\pcadmin\Downloads\" | where-object {$_.name -like "$exe_path"} | select-object -ExpandProperty PSChildName
    $exe_hash = Get-FileHash -Path "C:\Users\pcadmin\Downloads\$find_exe_path" -Algorithm SHA256
    $result = Compare-Object -ReferenceObject "$download_hash" -DifferenceObject "$($exe_hash.Hash)"
    Write-Output $result

}
New-Alias chash Compare-Hashkey
Export-ModuleMember -Function Compare-Hashkey
Export-ModuleMember -Alias chash