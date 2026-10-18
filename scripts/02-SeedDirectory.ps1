#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory
$ErrorActionPreference='Stop'
if((Get-ADDomain).DNSRoot -ne 'corp.lab.test'){throw 'Wrong domain'}
$base='DC=corp,DC=lab,DC=test'
foreach($ou in 'People','ServiceAccounts','Groups','Workstations','Servers'){
 if(-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $base -SearchScope OneLevel)){
  New-ADOrganizationalUnit -Name $ou -Path $base -ProtectedFromAccidentalDeletion $true
 }
}
foreach($g in 'Helpdesk-Lab','Server-Operators-Lab','Employees-Lab'){
 if(-not (Get-ADGroup -Filter "SamAccountName -eq '$g'")){
  New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path "OU=Groups,$base"
 }
}
foreach($u in 'alice.lab','bob.lab','analyst.lab','svc_web_lab'){
 if(-not (Get-ADUser -Filter "SamAccountName -eq '$u'")){
  $pw=Read-Host "Unique strong password for $u" -AsSecureString
  $ou=if($u -eq 'svc_web_lab'){'ServiceAccounts'}else{'People'}
  New-ADUser -Name $u -SamAccountName $u -UserPrincipalName "$u@corp.lab.test" -Path "OU=$ou,$base" -AccountPassword $pw -Enabled $true
 }
}
Add-ADGroupMember 'Employees-Lab' -Members 'alice.lab','bob.lab','analyst.lab'
# An SPN alone does not mean a weak password, active HTTP service or admin access.
$svc=Get-ADUser svc_web_lab -Properties ServicePrincipalNames
if($svc.ServicePrincipalNames -notcontains 'HTTP/SRV01.corp.lab.test'){
 Set-ADUser svc_web_lab -ServicePrincipalNames @{Add='HTTP/SRV01.corp.lab.test'}
}
Get-ADUser svc_web_lab -Properties ServicePrincipalNames | Select-Object 'SamAccountName','ServicePrincipalNames'
