function Prompt {
        $Host.UI.RawUI.WindowTitle = Get-Location
        $date = Get-Date
        "$($date.Hour).$($date.Minute).$($date.second) PS> "
}

$vault                  = "C:\ADMIN\The_Vault"
$mgTools                = "$vault\MG-Tools"
$reportingKit           = "$mgTools\reportingKit"
$rmmKit                 = "$mgTools\rmmKit"
$toolKit                = "$mgTools\toolKit"
$transcripts            = "$vault\PS_Transcripts"


function Start-Profile {
        BEGIN {
                $date = Get-Date | Select-Object -expandproperty 'Dayofyear'
                Start-Transcript -Path "$transcripts\$date.dayof2023.txt" -Append
        }
        PROCESS {
            $rmmKitModules  = Get-ChildItem $rmmKit\*
            $toolKitModules = Get-ChildItem $toolKit\*
            Import-Module ActiveDirectory
            foreach ($rmmModule in $rmmKitModules) {
                try {
                    Import-Module $rmmModule.Fullname -ErrorAction SilentlyContinue
                    Write-Output "$rmmModule.name has been loaded."
                }
                catch {
                    Write-Output "$rmmModule.name is not ready and has not been loaded."
                }

            foreach ($toolModule in $toolKitModules) {
                try {
                    Import-Module $toolModule.Fullname -ErrorAction SilentlyContinue
                    Write-Output "$toolModule.name has been loaded."
                }
                catch {
                    Write-Output "$toolModule.name is not ready and has not been loaded."
                }
            }
        }
    }
    
    END {Set-Location "$progressscripts"}
}
#Start-Profile
