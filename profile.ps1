$vault      = "C:\ADMIN\The_Vault"
$mgTools    = "$vault\MG-Tools"
$transcripts= "$vault\PS_Transcripts"
$date       = Get-Date

function Prompt {
        $Host.UI.RawUI.WindowTitle = Get-Location
        "$($date.Hour).$($date.Minute).$($date.second) PS> "
}


function Start-Profile {
    $VerbosePreference= 'SilentlyContinue'
    #
    #
    #
    $otherModules = 'ActiveDirectory'
    foreach ($module in $otherModules) {
        try {
            Import-Module $module
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
            Import-Module $tool -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Unable to load $($tool.BaseName) into memory."
        }
    }
    Set-Location "$progressscripts"
}
Start-Profile

function New-Transcript {
    $transcriptpath = "$transcripts\$($date.DayOfYear).dayof2023.txt"
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
