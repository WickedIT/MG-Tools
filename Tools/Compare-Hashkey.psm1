function Invoke-FindFilePath {
    # Create a File Dialog box to let the user select a file.
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "All files (*.*)|*.*"
    $openFileDialog.Title = "Select a file"
    
    # Show the File Dialog box and get the selected file path.
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFilePath = $openFileDialog.FileName
        Write-Output $selectedFilePath
    } else {
        Write-Output "No file selected."
        return
    }

}
function Compare-Hashkey {
    $download_hash = Read-Host "Please enter the downloads expected sha256."
    $exe_path = Invoke-FindFilePath #Read-Host "Please provide the name of the file."
    #$find_exe_path = Get-ChildItem -Path "C:\Users\pcadmin\Downloads\" | where-object {$_.name -like "$exe_path"} | select-object -ExpandProperty PSChildName
    $exe_hash = Get-FileHash -Path "$exe_path" -Algorithm SHA256
    $result = Compare-Object -ReferenceObject "$download_hash" -DifferenceObject "$($exe_hash.Hash)"
    Write-Output $result

}
New-Alias chash Compare-Hashkey
Export-ModuleMember -Function Compare-Hashkey
Export-ModuleMember -Alias chash

