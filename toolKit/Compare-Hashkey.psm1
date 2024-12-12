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
    } 
    else {
        Write-Error "No file selected."
    }
}
function Compare-Hashkey {
    $download_hash = Read-Host "Please enter the downloads expected sha256."#Queries for the expected hashkey in terminal
    $exe_path = Invoke-FindFilePath #Invokes the dialog box.
    $exe_hash = Get-FileHash -Path "$exe_path" -Algorithm SHA256 #Generates the hashkey for the selected file.
    $result = Compare-Object -ReferenceObject "$download_hash" -DifferenceObject "$($exe_hash.Hash)" #Compares the two hashes.
    if ($null -eq $result) {#Displays whether hash is correct or not, if not it displays the files hash.
        Write-Host "The Hash code is correct!"
    }
    else {
    Write-Host $result
    }
}
New-Alias chash Compare-Hashkey
Export-ModuleMember -Function Compare-Hashkey
Export-ModuleMember -Alias chash

