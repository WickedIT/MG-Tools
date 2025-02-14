#Requires -module PSWindowsUpdate
function Invoke-UpdateCollector {
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]$Computername,
        [Parameter(Mandatory=$false)]$Path
    )
    
}