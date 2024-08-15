function Get-LastBoot {
    param(
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True
    )]
    $computername='localhost'
    )
    #Provide easy uptime stats for localhost or remote pc's. 
    #Including day and time of last boot and hours since last boot
}