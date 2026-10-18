#Requires -RunAsAdministrator
$ErrorActionPreference='Stop'
if($env:COMPUTERNAME -ne 'DC01'){throw 'DC01 only'}
if(-not (Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -eq '10.77.10.10')){throw 'Lab IP missing'}
if((Get-CimInstance Win32_ComputerSystem).PartOfDomain){throw 'Already joined; do not recreate forest'}
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
$dsrm=Read-Host 'Choose a unique DSRM recovery password' -AsSecureString
Install-ADDSForest -DomainName 'corp.lab.test' -DomainNetbiosName 'CORPLAB' -InstallDNS -SafeModeAdministratorPassword $dsrm -Force
