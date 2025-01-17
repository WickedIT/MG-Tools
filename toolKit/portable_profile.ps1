$vault      = "$env:USERPROFILE"
$git        = "$vault\GitHub"
$mgTools    = "$git\MG-Tools"
$transcripts= "$git\PS_Transcripts"


function Prompt {
    $date = Get-Date
    $Host.UI.RawUI.WindowTitle = Get-Location
    "$($date.Hour).$($date.Minute).$($date.second) PS> "
}


function Start-Profile {
    $VerbosePreference= 'SilentlyContinue'
    #
    #
    #
    $otherModules = 'ActiveDirectory', 'ADSync'
                    #'C:\Program Files\Microsoft Azure AD Connect Provisioning Agent\Utility\AADCloudSyncTools.psm1',
                    #'C:\Program Files\Microsoft Azure AD Connect Provisioning Agent\Utility\ADConnectivityTool.psm1'
    foreach ($module in $otherModules) {
        try {
            Import-Module $module -ErrorAction Continue
        }
        catch {
            Write-Error "Unable to load $module in to memory."
        }
    }
    #
    #
    #
    $toolkit = Get-ChildItem -Recurse -Path $mgTools -Filter "*.psm1"
    foreach ($tool in $toolkit) {
        try {
            Import-Module $tool -ErrorAction Continue
            #Write-Host "$($tool.BaseName) has been loaded into memory."
        }
        catch {
            Write-Error "Unable to load $($tool.BaseName) into memory."
        }
    }
    Set-Location "$git"
}
Start-Profile

function New-Transcript {
    $date = Get-Date
    $transcriptpath = "$transcripts\$($date.DayOfYear).dayof_$($date.Year).txt"
    if ( ! (Test-Path -Path $transcriptpath)) {
        Write-Host "Starting a new transcript for the day! Happy Labbing!" -ForegroundColor Green -BackgroundColor DarkGray
    }
    else{
        Write-Host "Continuing today's session..." -ForegroundColor Green -BackgroundColor DarkGray
    }
    Start-Transcript -Path $transcriptpath -Append
    #

}
New-Transcript

function Invoke-UnixUpdateCheck {
    $update_logs = Get-ChildItem -Path 'Z:\forLab\script_Outputs\+nix_updates\' -File
    $cutoff = (Get-Date).AddDays(-15)
    foreach ($l in $update_logs) {
        if (((Get-Item -Path $l).LastWriteTime) -lt $cutoff) {
            Write-Host "Host $($l.BaseName) has not been updated in the last 15 days. Please consider resolving."
        }
    }
}
Invoke-UnixUpdateCheck
