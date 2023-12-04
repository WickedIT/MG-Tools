function Test-PCs {
    BEGIN {
            $computers
    }
    PROCESS {
        foreach ($computer in $computers) {
            #$ComputerName = $Computer.DistinguishedName.split(',')[0].split('=')[1]
            $result = Test-NetConnection -ComputerName $Computer
            $succeed = $result.PingSucceeded
            if ($succeed) 
            {
                $obj = [PSCustomObject] `
                @{
                    Name = $computer
                    T_F = $Succeed
                }
                Write-Output $obj
                $obj | Select-Object -ExpandProperty 'Name' | Out-File 
            }
            else 
            {
                $obj = [PSCustomObject] `
                @{
                    Name = $computer
                    T_F = $succeed
                }
                Write-Output $obj
                $obj | Select-Object -ExpandProperty 'Name' | Out-File 
            }
        }
    }
    END {
    }       
}
Test-PCs