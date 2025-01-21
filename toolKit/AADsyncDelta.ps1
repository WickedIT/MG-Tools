Invoke-command -ComputerName vm-toolbox -Credential (Get-Credential) -scriptblock {
    Start-ADSyncSyncCycle -PolicyType Delta
}