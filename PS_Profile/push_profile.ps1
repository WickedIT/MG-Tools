function Invoke-ProfilePush {
    #Get list of windows PCs in the ORG
    $computers = get-adcomputer -filter * -Properties OperatingSystem | Select-Object name,operatingsystem | where-object -property Operatingsystem -Like "*Windows*"
    #test for the profile file and cp if there is none
    foreach ($computer in $computers) {
        $Continue = Test-Path \\$computer\$PSHome
    }
}