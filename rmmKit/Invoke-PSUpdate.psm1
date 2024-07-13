function Invoke-PSUpdate {
    <#
    Add param block for some variables like dumpdir and the list of computers
    Add more logic, error handling, and features (like making automatable.)
    #> 
#common variables
$dumpDir = "C:\admin\Development\Updates"
#Gets list of PC's in domain that are windows.
$listOfServers = Get-ADComputer -filter * -Properties OperatingSystem | Where-Object -Property Operatingsystem -like "*Windows*" | Select-Object -ExpandProperty Name
#Loop to check for updates, if available then store PC name and pass to update loop.
foreach ($server in $listOfServers) {
    $availUpdates = Get-WindowsUpdate -computername $server
    if ($null -ne $availUpdates) {
        $needsUpdates += "$server"
    }
    else{
        Write-Output "$server does not need to be updated" | Out-File $dumpDir\updateNA.txt
    }
    Clear-Variable availUpdates

}
$cred = Get-Credential -Message "Please enter credentials for a 'Domain Admin' account"

#text file to catch update output
$newtxtfile = New-Item -path "$dump_dir/$textfilepath" -name "svrUpdated.txt" -ItemType "file"

Write-Output "$newtxtfile was created."

$updateOutput = foreach ($svr in $availUpdates) {
    Invoke-WUJob -ComputerName $svr -Script { Install-WindowsUpdate -AcceptAll -SendReport -IgnoreReboot } -Confirm:$false -verbose -RunNow

}
}
#Export-ModuleMember -Function Invoke-psUpdate