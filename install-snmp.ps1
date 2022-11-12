Write-Host "==================================================="
Write-Host "                SNMP Role Install                  "
Write-Host "==================================================="

## Variables

$CollectionHost = X.X.X.X #Input IP or hostname
$SNMPCommunity = "example" #Input SNMP Community String

Install-WindowsFeature SNMP-Service

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name $SNMPCommunity -Value 4 -type DWord

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" -Name "1" -Value $CollectionHost -type String 

Restart-Service -Name SNMP
