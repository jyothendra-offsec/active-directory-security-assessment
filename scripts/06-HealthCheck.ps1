#Requires -RunAsAdministrator
$ErrorActionPreference='Stop'
Get-CimInstance Win32_ComputerSystem | Select-Object 'Name','Domain','PartOfDomain'
Resolve-DnsName '_kerberos._tcp.corp.lab.test' -Type SRV -Server 10.77.10.10
w32tm /query /status
if($env:COMPUTERNAME -eq 'DC01'){
 dcdiag /test:DNS /v
 Get-ADDomain | Select-Object 'DNSRoot','DomainMode','PDCEmulator'
 Get-SmbShare -Name 'SYSVOL','NETLOGON'
}else{Test-ComputerSecureChannel -Verbose}
Get-NetFirewallProfile | Select-Object 'Name','Enabled','DefaultInboundAction'
