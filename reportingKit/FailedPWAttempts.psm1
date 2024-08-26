function Get-ADUserFailedLoginAttempts {
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelinebyPropertyName=$true
        )]
        $Identity
    )
    BEGIN {}
    PROCESS {
        Get-Aduser -Identity $Identity -Properties badpwdcount,LastBadPasswordAttempt | Select-Object name,badpwdcount,LastBadPasswordAttempt
    }
    END {}
}



# Get security event log and filter for failed logon attempts
function Get-LocalFailedLoginAttempts {
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4625
    } | ForEach-Object {
        # Extract relevant properties
        $eventProperties = [PSCustomObject]@{
            TimeCreated = $_.TimeCreated
            User = $_.Properties[5].Value
            LogonType = Invoke-ParseLogonType $_.Properties[10].Value}
        Write-OutPut @eventProperties
        }

    # Display the results
    $events | Format-List
}


function Invoke-ParseLogonType($logonType) {
    switch ($logonType) {
        2 { return "Interactive (logon at keyboard and screen)" }
        3 { return "Network (e.g., mapping network drive)" }
        4 { return "Batch (e.g., scheduled task)" }
        5 { return "Service (Service startup)" }
        7 { return "Unlock (Workstation unlocked)" }
        8 { return "NetworkClearText (Network logon with clear text credentials)" }
        9 { return "NewCredentials (RunAs using alternate credentials)" }
        10 { return "RemoteInteractive (RDP or similar)" }
        11 { return "CachedInteractive (logon using cached credentials)" }
        default { return "Unknown" }
    }
}