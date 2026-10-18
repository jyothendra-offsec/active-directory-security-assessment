#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
if((Get-CimInstance Win32_ComputerSystem).Domain -ne 'corp.lab.test'){throw 'Wrong domain'}
$stamp=(Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$dest=Join-Path $OutputDirectory "$env:COMPUTERNAME-$stamp"
New-Item -ItemType Directory -Path $dest -ErrorAction Stop | Out-Null
foreach($log in 'Security','Microsoft-Windows-PowerShell/Operational'){
 $file=($log -replace '[/\\]','_')+'.evtx'
 & wevtutil.exe epl $log (Join-Path $dest $file)
 if($LASTEXITCODE -ne 0){throw "Export failed: $log"}
}
Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption','Version','BuildNumber' | ConvertTo-Json | Set-Content (Join-Path $dest 'os.json')
Get-ChildItem $dest -File | Get-FileHash -Algorithm SHA256 | Select-Object 'Path','Hash' | Export-Csv (Join-Path $dest 'manifest.csv') -NoTypeInformation
Write-Host "Evidence saved locally: $dest. Review and redact before sharing."
