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
    param(
        [Parameter()]
        [string]$Path=(Invoke-FindFilePath),
        #
        [Parameter(Mandatory)]
        [string]$ExpectedHash,
        #
        [Parameter()]
        [string]$Algorithm='SHA256'
    )
    try {
        $ActualHash = Get-FileHash -Path "$path" -Algorithm $Algorithm #Generates the hashkey for the selected file.
        if ($ActualHash -eq $ExpectedHash) {#Displays whether hash is correct or not.

            return "It's a match!"
        }
        else {
            throw "It's not a match. Please verify the download."
        }
    }
    catch {
        $_
    }
}
New-Alias chash Compare-Hashkey
