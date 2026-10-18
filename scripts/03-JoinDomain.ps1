#Requires -RunAsAdministrator
$ErrorActionPreference='Stop'
if($env:COMPUTERNAME -notin @('SRV01','WS01')){throw 'SRV01 or WS01 only'}
if((Get-CimInstance Win32_ComputerSystem).PartOfDomain){throw 'Already joined; inspect membership'}
Resolve-DnsName '_ldap._tcp.dc._msdcs.corp.lab.test' -Type SRV -Server 10.77.10.10
$ou=if($env:COMPUTERNAME -eq 'SRV01'){'Servers'}else{'Workstations'}
Add-Computer -DomainName 'corp.lab.test' -OUPath "OU=$ou,DC=corp,DC=lab,DC=test" -Credential (Get-Credential -Message 'Lab domain join account') -Restart
