Write-Host "==================================================="
Write-Host "                SNMP Role Install                  "
Write-Host "==================================================="

## Variables

$CollectionHost = 10.4.20.19
$SNMPCommunity = dreddrealm

Install-WindowsFeature SNMP-Service

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name $SNMPCommunity -Value 4 -type DWord

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" -Name "1" -Value $CollectionHost -type String 

Restart-Service -Name SNMP
