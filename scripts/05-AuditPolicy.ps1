#Requires -RunAsAdministrator
$ErrorActionPreference='Stop'
if((Get-CimInstance Win32_ComputerSystem).Domain -ne 'corp.lab.test'){throw 'Wrong domain'}
# English Windows subcategory names. For other locales use auditpol /list /subcategory:* /v.
$categories=@('Logon','Account Lockout','Special Logon','User Account Management','Security Group Management','Process Creation')
if($env:COMPUTERNAME -eq 'DC01'){$categories+=@('Kerberos Authentication Service','Kerberos Service Ticket Operations','Credential Validation','Directory Service Changes')}
foreach($s in $categories){
 & auditpol.exe /set "/subcategory:$s" /success:enable /failure:enable
 if($LASTEXITCODE -ne 0){throw "auditpol failed: $s"}
}
& auditpol.exe /get /category:*
Write-Host 'Local audit baseline; domain policy may override. Verify after gpupdate. Object changes require matching SACLs.'
