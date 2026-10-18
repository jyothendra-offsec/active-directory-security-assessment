# Assessment runbook

Every exercise begins with a baseline checkpoint, scope entry, tool version, UTC start time, named test account and logging verification. Capture stdout/stderr and exit status. Redact only a copy; hash and retain the original privately. A prevention result is a valid result.

## A. Directory enumeration and attack-path review

Run under `CORPLAB\analyst.lab` on WS01. Download SharpHound CE from SpecterOps and follow the matching CE documentation. Start with directory relationships rather than session collection:

```powershell
.\SharpHound.exe --CollectionMethods Group,ACL,ObjectProps,Container,Trusts --Domain corp.lab.test --OutputDirectory C:\LabEvidence
```

Verify supported collection methods with that binary's `--help`. Import the ZIP into a locally deployed BloodHound CE instance (official quickstart). Do not upload directory data to a public demo. BloodHound runs separately on AUDIT01 or a dedicated analysis VM if resources permit; allocate extra RAM if needed.

Inspect memberships, ACL ownership/write rights, OU containment and any paths to privileged groups. A missing edge can reflect collection limits; it is not proof of no access. For the optional SRV01 local-admin relationship, endpoint collection such as LocalAdmin requires relevant reachability and permissions; explicitly record the expanded collection scope. Directory-only collection cannot establish current sessions or all local memberships.

Cross-check selected objects with native AD cmdlets on DC01 and PowerView on the test endpoint:

```powershell
# Import only your reviewed, version-recorded PowerView.ps1 from PowerSploit.
Import-Module .\PowerView.ps1
Get-DomainUser -Identity svc_web_lab -Properties samaccountname,serviceprincipalname
Get-DomainGroupMember -Identity Helpdesk-Lab
Get-DomainObjectAcl -Identity Helpdesk-Lab -ResolveGUIDs
```

Record one relationship at a time: principal, right, object, inheritance, scope, and required session/network conditions. Export a redacted graph screenshot only after actual collection. Baseline contains no pre-seeded Domain Admin compromise path.

## B. Kerberoasting — T1558.003

Prerequisites: valid low-privilege domain credential, reachable KDC, SPN-bearing user account, synchronized time. On AUDIT01, Fortra Impacket's GetUserSPNs example can enumerate the lab SPN and request a service ticket:

```bash
# Distribution packages may name this impacket-GetUserSPNs.
GetUserSPNs.py corp.lab.test/analyst.lab -dc-ip 10.77.10.10 -request -outputfile lab-tgs.txt
```

Let the tool prompt for the password. Store output privately. A TGS request demonstrates access to encrypted service-ticket material, not password recovery. Do not assume RC4; record the actual encryption type. Offline password testing against the separate intentionally weak identity is optional; record the exact candidate set, runtime and outcome, and never report the baseline password as cracked without evidence.

Evidence: DC 4769, account/SPN, requester, time, encryption type, tool result hash. Expected: service ticket request can succeed for a valid account; recovery depends on password strength and encryption. Remediate human-managed service secrets using gMSA where supported, remove unnecessary SPNs/privileges, and retest business functionality. AES alone does not eliminate offline guessing.

## C. Password spraying — T1110.003

Read effective domain and fine-grained lockout policies first. Restrict the exercise to `alice.lab` and `bob.lab`; check each account's existing bad-password/lockout state. Perform **one** controlled wrong-password attempt per account using an interactive lab SMB authentication prompt. Do not build a retry loop, rotate sources or attempt to evade monitoring. Log off or clear existing authenticated SMB sessions first so cached sessions do not mask the test. Stop on lockout or unexpected state.

This is a two-account detection validation, not a meaningful password-strength survey. Record protocol negotiation: NTLM may yield DC 4776 and target 4625; Kerberos failures may yield DC 4771 instead. Correlate the same source and attempted password campaign across identities without storing the actual password in reports. Remediate with password screening, suitable lockout policy, monitoring and controls on exposed authentication surfaces. MFA coverage must be evaluated per protocol; it is not automatically enforced on legacy SMB/NTLM.

## D. Pass-the-Hash — T1550.002

Requires an already-known disposable **lab account NT hash**, NTLM support, a reachable service, and account authorization on that target. The baseline provides none of these credentials. Generate/provision the disposable test identity under lab administration; do not collect real credential stores. Record provenance privately. Use Impacket's documented SMB client hash authentication mode against SRV01 after the explicit TCP 445 exception. Keep secrets out of shell history/process listings where possible; review tool input handling before use.

First validate low-privilege access, then test a harmless read of a dedicated lab share. Only test administrative access if that separate privilege was intentionally configured. Never infer local-admin access solely from successful NTLM authentication. No remote payload or persistence is needed.

Evidence: target logon 4624 (often type 3), authentication package, share access/denial, source IP, DC credential validation when applicable, firewall counters. These logs alone do not distinguish a hash from a password. Compare with a normal password-based NTLM login as a negative control. Remediate shared local credentials with Windows LAPS, reduce NTLM following compatibility assessment, restrict admin paths and enforce tier separation. SMB signing mitigates relay, not possession-based hash authentication.

## E. Privilege relationships and lateral movement

Use the optional Helpdesk-Lab -> SRV01 local Administrators condition from LAB-SETUP. Authenticate as the intentionally added member and confirm the effective token/authorized action on SRV01; collect `whoami /groups` in the relevant logon context. Group membership, remote UAC filtering, network reachability and service configuration can change the result. This is member-server local privilege, not domain privilege.

Compare before/after removing the delegation and closing the router exception. Retest with a fresh logon to avoid cached tokens. Keep proofs to reading a non-sensitive lab marker or an explicitly authorized administrative status query; do not introduce persistence. Map SMB administrative access to T1021.002 only if used; map RDP to T1021.001 only if actually used. A firewall deny is segmentation evidence when corroborated with a known listener and counters.

## F. Golden Ticket — T1558.001 (advanced, manual)

This is a **post-domain-compromise** scenario: it requires domain SID and the KRBTGT signing key plus compatible ticket parameters. It is not a route from an ordinary user to initial domain compromise. No KRBTGT extraction, forged-ticket generation or automatic injection is bundled here.

In a separate disposable clone, an experienced operator can validate the scenario using an explicitly provisioned lab key and the chosen tool's official documentation. Record the key provenance, domain, ticket lifetime, encryption type, account identity and exact patch level privately. Confirm acceptance against a harmless lab resource and compare with a normal KDC-issued ticket. If not executed, keep this item as NOT RUN and describe it as a threat-model/detection exercise in interviews.

Look for inconsistent ticket/logon properties and correlate DC 4768/4769 with target activity; a missing 4768 alone is not conclusive because of cached tickets, retention and distributed logs. Remediation involves domain recovery, removing the compromise source, and a carefully planned **two-stage KRBTGT reset** with replication and ticket lifetime considerations. Do not perform blind back-to-back resets or present a simple password change as complete recovery.

## Completion gate

For each row in the ledger, state PASS / PREVENTED / FAILED / INCONCLUSIVE only with an evidence identifier. Record the remediation and repeat the same source, target, identity and operation. Keep initial and retest evidence separate. Restore the coordinated baseline after the exercise.
