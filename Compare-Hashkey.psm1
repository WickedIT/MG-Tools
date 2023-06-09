function Compare-Hashkey {
    $download_hash = Read-Host "Please enter the downloads expected sha256."
    $exe_path = Read-Host "Please provide the EXE's download path."
    $exe_hash = Get-FileHash -Path "$exe_path" -Algorithm SHA256
    $result = Compare-Object -ReferenceObject "$download_hash" -DifferenceObject "$($exe_hash.Hash)"
    Write-Output $result

}
New-Alias chash Compare-Hashkey
Export-ModuleMember -Function Compare-Hashkey
Export-ModuleMember -Alias chash