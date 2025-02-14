<#
function Get-ManagedUser {
  param([Parameter(Mandatory)]$Servers)
  $result = [System.Collections.Arraylist]::new()
  foreach ($server in $servers) {
    try {
      $computer = Get-ADComputer -Properties Name,ManagedBy -Filter "Name -like '$($server)*'" | Select-Object Name,ManagedBy
    $user = ($computer.ManagedBy | Get-Aduser -Properties DisplayName).DisplayName
    $collection = [PSCustomObject]@{
      Name = "$($computer.Name)"
      ManagedBy = "$user"
    }
    $result.Add($collection)
  }
  Write-Output $result
}
#>