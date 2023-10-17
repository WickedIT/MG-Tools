function Prompt {
    $host.UI.RawUI.WindowTitle = Get-Location
    $date = Get-Date
    "$($date.Hour).$($date.Minute).$($date.second) PS> "
}
$vault                  = "D:\The_Vault"
$git			= "$vault\Git\Development\MG-Tools"
$donescripts            = "$vault\Code_Done"
$progressscripts        = "$vault\Code_Progress"
$transcripts            = "$vault\PS_Transcripts"
$sshkey			= "C:\Users\pcadmin\.ssh"

function Start-Profile {
    BEGIN {
            $date = Get-Date | Select-Object -expandproperty 'Dayofyear'
            Start-Transcript -Path "$transcripts\$date.dayof2023.txt" -Append
    }
    PROCESS {
            #Import-Module "$donescripts\Find-AdComputer.psm1"
            #Import-Module "$donescripts\Find-ADUser.psm1"
            Import-Module "$donescripts\Random_Password.psm1"
            #Import-Module ActiveDirectory
    Import-Module "$git\Tools\Compare-HashKey.psm1"
    }
    END {Set-Location "$progressscripts"}
}
Start-Profile