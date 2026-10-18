# Build the lab

## 1. Prepare and isolate

Use VirtualBox or an equivalent hypervisor. Create the five VMs listed in the README. Install Windows Server 2022 Desktop Experience on DC01/SRV01, Windows 11 Pro or Enterprise on WS01 (Home cannot join AD), Debian on FW01 and Linux on AUDIT01. Set the Windows machines to an English locale for the supplied audit policy names. Use separate unique administrative passwords.

Download tools from the official references, record versions and SHA256 values in `templates/tool-inventory.csv`, and install updates before taking the offline checkpoint. Do not pin to an arbitrary untested tool version: record the exact versions you actually use and match SharpHound to the BloodHound CE release. The repository does not redistribute third-party tools or operating systems.

In VirtualBox VM Settings > Network, configure only these Internal Network adapters:

| Machine | Adapter 1 | Adapter 2 | Adapter 3 |
|---|---|---|---|
| DC01 | AD-ID | disabled | disabled |
| SRV01 | AD-SRV | disabled | disabled |
| WS01 / AUDIT01 | AD-CLIENT | disabled | disabled |
| FW01 | AD-ID | AD-SRV | AD-CLIENT |

Disable shared folders, shared clipboard and drag-and-drop. Do not use bridged networking. Temporary NAT adapters used for installation must be removed before assessments. Internal networks do not provide host access; use VM consoles and a read-only ISO of this repository to transfer scripts if necessary.

## 2. Configure the router

Use the FW01 console. Identify adapters by MAC addresses from VirtualBox, not by guessing interface order. Assign `10.77.10.1/24`, `10.77.20.1/24`, `10.77.30.1/24` to the corresponding adapters through Debian's network manager or `/etc/network/interfaces`. No default gateway and no DNS forwarder are needed on the router.

Install nftables while staging the machine. Then, offline:

```bash
sudo nft -c -f config/router.nft    # syntax check before changing firewall
sudo nft -f config/router.nft
sudo sysctl -w net.ipv4.ip_forward=1
sudo nft list ruleset
ip -br address
ip route
```

Persist the reviewed rules to `/etc/nftables.conf`, enable the nftables service, and set `net.ipv4.ip_forward=1` in `/etc/sysctl.d/90-adlab.conf`. The provided rules replace the entire ruleset and belong ONLY on FW01. IPv6 forwarding remains denied by the inet forward policy; no IPv6 lab routing is configured. FW01 is administered through its console.

The policy permits client/member domain dependencies to DC01, including dynamic RPC, and denies client-to-SRV01 administration. This is a single-DC lab policy, not an enterprise firewall template. LDAP TLS ports are not enabled because no lab CA is provisioned; do not interpret this as an LDAPS deployment. ADWS 9389 is unnecessary for the supplied DC-local provisioning. See Microsoft's port guidance in REFERENCES.

Set AUDIT01 to `10.77.30.50/24`, gateway `10.77.30.1`, DNS `10.77.10.10`. Confirm its time matches DC01; configure NTP to the DC if supported. All systems need consistent time for Kerberos.

## 3. Configure Windows

Copy this repository into each Windows VM. Run an elevated **Windows PowerShell 5.1** console. Read scripts before execution. If a downloaded file is blocked, verify its provenance and use `Unblock-File` on the specific reviewed file; do not disable execution policy globally.

On each Windows machine, replace the interface alias with the actual name from `Get-NetAdapter`:

```powershell
.\scripts\00-Network.ps1 -Node DC01 -InterfaceAlias 'Ethernet'
Restart-Computer
```

Use `SRV01` and `WS01` on those machines. This script intentionally refuses an existing static IPv4 configuration or domain membership; inspect partial changes manually instead of repeatedly rerunning it.

On DC01:

```powershell
.\scripts\01-NewForest.ps1  # prompts for DSRM secret and reboots
# Sign in as CORPLAB\Administrator after reboot:
.\scripts\02-SeedDirectory.ps1
.\scripts\04-LoggingGPO.ps1
```

The seed script prompts for four unique passwords. Keep them in a local vault. `svc_web_lab` receives an HTTP SPN, but no service is installed and no password weakness/admin privilege is granted. The groups initially carry no delegated rights. This is deliberate: the baseline should not silently manufacture vulnerabilities.

On SRV01 and WS01:

```powershell
.\scripts\03-JoinDomain.ps1 # prompts for a lab domain join credential and reboots
```

On all three Windows machines:

```powershell
gpupdate /force
.\scripts\05-AuditPolicy.ps1
.\scripts\06-HealthCheck.ps1
gpresult /h C:\Windows\Temp\lab-gpresult.html
```

Verify healthy DNS, SYSVOL/NETLOGON, domain membership, time and effective policy. Audit policy is configured locally; a later domain GPO may override it. Recheck `auditpol /get /category:*` after every policy refresh. Configure a sufficient Security log size/retention through Event Viewer; record the chosen size and export before rollover.

## 4. Baseline and checkpoints

From WS01 run `08-TestSegmentation.ps1 -OutputCsv C:\Windows\Temp\baseline.csv`. TCP 53/88 on DC01 should connect. SRV01 445/3389/5985 should fail. Validate the destination listener and FW01 counters: a stopped service also produces a failed connection.

Record OS builds, tool versions, addresses, firewall policy hash, timestamps and health-check output. Power off all lab VMs and take a coordinated `baseline-clean` checkpoint. Resume the set together. Take another checkpoint before each optional weakness. Never mix restored DC state with members from a different checkpoint.

## 5. Optional exercise conditions

For a lateral-movement exercise, add ONE temporary FW01 exception from AUDIT01 to SRV01 TCP 445, and enable only the corresponding server service/firewall rule needed for that experiment. Document it as an intentional change, not a baseline property. Delete the rule by its displayed nftables handle or reload the baseline policy afterward.

For a privilege relationship exercise, deliberately add `CORPLAB\Helpdesk-Lab` to the **SRV01 local** Administrators group and `alice.lab` to Helpdesk-Lab. Do this only after the checkpoint and record both changes. Remove the memberships afterward and reauthenticate so stale tokens do not invalidate the retest. Do not add these groups to Domain Admins.

For a weak-password service-account exercise, use a separate disposable test identity and an operator-chosen lab-only password; do not weaken the default domain policy or reuse the baseline service password. If policy prevents your proposed password, record prevention or choose a compliant test password. A successful offline recovery is optional and must be evidenced separately.

## Troubleshooting

| Symptom | Check |
|---|---|
| Domain not found | Client DNS must be DC01, router paths, DNS SRV records |
| Join fails after DNS succeeds | RPC dynamic ports, endpoint firewall, time, credentials |
| GPO absent | Computer OU, security filtering, SYSVOL, gpresult |
| Empty BloodHound relationships | Collector permissions, methods, endpoint reachability and data age |
| No event 4769 | Query DC Security log, effective audit policy, ticket cache |
| TCP blocked unexpectedly | Actual listener, endpoint firewall, router counters, source address |
| Kerberos clock skew | DC/client time and hypervisor time synchronization |
