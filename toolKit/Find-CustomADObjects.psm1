function Find-ADuser {
    param([Parameter(Mandatory=$True,Position=0)]$Identity)
    $UserProps = 'City','Title','Manager','MemberOf','telephonenumber','Department'
    if ($Identity -eq '*') {
        Get-AdUser -Filter $Identity -Properties $UserProps
    }
    else {
        Get-ADUser -Identity $Identity -Properties $UserProps
    }
}
New-Alias fadu Find-ADUser



function Find-ADComputer {
    param([Parameter(Mandatory=$True,Position=0)]$Identity)
    $CompProps = 'description','OperatingSystem','ipv4address'
    if ($Identity -eq '*') {
        Get-ADComputer -Filter $Identity -Properties $CompProps
    }
    else {
        Get-ADComputer -Identity $Identity -Properties $CompProps
    }
}
New-Alias fadc Find-ADComputer
