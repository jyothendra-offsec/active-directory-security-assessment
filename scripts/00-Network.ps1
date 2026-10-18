#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][ValidateSet('DC01','SRV01','WS01')][string]$Node,
      [Parameter(Mandatory)][string]$InterfaceAlias)
$ErrorActionPreference='Stop'
$c=Get-Content "$PSScriptRoot\..\config\topology.json" -Raw | ConvertFrom-Json
$n=$c.nodes | Where-Object name -eq $Node
$up=@(Get-NetAdapter | Where-Object Status -eq 'Up')
if($up.Count -ne 1 -or $up[0].Name -ne $InterfaceAlias){throw 'Require exactly one active lab adapter.'}
if((Get-CimInstance Win32_ComputerSystem).PartOfDomain){throw 'Configure network before domain join.'}
if(Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 | Where-Object PrefixOrigin -eq Manual){throw 'Manual IPv4 exists; inspect it before changing.'}
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -Dhcp Disabled
Get-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $n.ip -PrefixLength 24 -DefaultGateway $n.gateway
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses '10.77.10.10'
if($env:COMPUTERNAME -ne $Node){Rename-Computer -NewName $Node -Force}
Write-Host 'Reboot before the next script. Verify isolation in the hypervisor.'
