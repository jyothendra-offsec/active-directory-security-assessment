[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputCsv)
$ErrorActionPreference='Stop'
if($env:COMPUTERNAME -ne 'WS01'){throw 'Run from WS01'}
$cases=@(@{Host='10.77.10.10';Port=53;Expected=$true},@{Host='10.77.10.10';Port=88;Expected=$true},@{Host='10.77.20.20';Port=445;Expected=$false},@{Host='10.77.20.20';Port=3389;Expected=$false},@{Host='10.77.20.20';Port=5985;Expected=$false})
$cases | ForEach-Object {
 $ok=Test-NetConnection -ComputerName $_.Host -Port $_.Port -InformationLevel Quiet -WarningAction SilentlyContinue
 [pscustomobject]@{UTC=(Get-Date).ToUniversalTime().ToString('o');Source=$env:COMPUTERNAME;Destination=$_.Host;Port=$_.Port;Expected=$_.Expected;Observed=$ok;Match=($ok -eq $_.Expected)}
} | Export-Csv $OutputCsv -NoTypeInformation
# A failed TCP connection alone cannot attribute a block to the router; correlate counters/logs and confirm the destination listener.
