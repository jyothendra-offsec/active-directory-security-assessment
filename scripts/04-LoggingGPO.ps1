#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory,GroupPolicy
$ErrorActionPreference='Stop'
if((Get-ADDomain).DNSRoot -ne 'corp.lab.test'){throw 'Wrong domain'}
$name='LAB-PowerShell-Logging'
$g=Get-GPO -Name $name -ErrorAction SilentlyContinue
if(-not $g){$g=New-GPO -Name $name}
Set-GPRegistryValue -Name $name -Key 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ValueName EnableScriptBlockLogging -Type DWord -Value 1 | Out-Null
foreach($ou in 'Workstations','Servers','Domain Controllers'){
 $target="OU=$ou,DC=corp,DC=lab,DC=test"
 $links=(Get-GPInheritance -Target $target).GpoLinks
 if($links.DisplayName -notcontains $name){New-GPLink -Name $name -Target $target | Out-Null}
}
Write-Host 'Run gpupdate /force on each machine; verify with gpresult. Script blocks may contain secrets.'
