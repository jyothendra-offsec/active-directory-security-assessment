# Explain the project accurately

## 60-second overview

“This project is an isolated Active Directory assessment lab with a domain controller, member server, workstation, assessment host and routed firewall. PowerShell scripts configure identity objects and logging. The assessment workflow uses directory relationships to form attack-path hypotheses, validates prerequisites through controlled exercises, collects Windows and network evidence, and repeats the tests after remediation. The repository separates designed scenarios from executed results.”

Before saying “I performed” or “I demonstrated,” point to your own completed ledger row. At repository creation, no Windows exercise has been executed. Your resume's completed-action claims require you to run the lab and retain evidence; until then say “designed and implemented the lab automation and assessment methodology.”

## Walk through the design

1. Identity tier: DC01 provides AD DS, DNS and Kerberos. Clients use its DNS and synchronize time.
2. Resource tier: SRV01 is a domain member; local administrator rights here do not imply Domain Admin.
3. Client tier: WS01 and AUDIT01 share a lab subnet. This is a limitation: the routed firewall cannot filter their same-subnet traffic.
4. Boundary: FW01 permits necessary domain traffic and blocks client-to-member management by default. Different IP ranges alone are not segmentation.
5. Evidence: compare a baseline, one intentional change, the observed result, and a matched retest.

## Questions you should be able to answer

**BloodHound vs SharpHound?** SharpHound collects relationships; BloodHound stores/visualizes/analyzes them. The graph does not automatically prove exploitability and collection may be incomplete.

**PowerView vs Impacket?** PowerView supports PowerShell-based directory inspection. Impacket is a Python protocol library with example tools for interactions such as Kerberos/SMB. Their exact use and versions belong in the ledger.

**Kerberoasting vs Golden Ticket?** Kerberoasting requests service tickets and may enable offline guessing of a service account's secret. Golden Ticket abuse forges a TGT using the KRBTGT key after a severe prior compromise. They have different prerequisites and remediation.

**Pass-the-Hash vs Pass-the-Ticket?** The first uses an NT hash for compatible NTLM authentication; the second uses Kerberos ticket material. Neither bypasses all authorization or network controls.

**Why not say SMB signing fixes Pass-the-Hash?** Signing protects message integrity and helps prevent relay; possession of valid authentication material is a different issue.

**Does 4769 prove Kerberoasting?** No. Normal service use requests tickets too. Evaluate requester, target services, frequency, encryption and baseline behavior.

**Why no universal detection accuracy?** No labeled experiment set exists yet. Event visibility and prevention depend on settings, versions and protocols.

**What did you actually automate?** Static host networking, AD forest creation, directory seeding, domain join, a logging GPO, local advanced audit policy, health checks, evidence exports and selected TCP reachability tests. VM/OS installation and advanced attack execution remain manual.

**Why is this not a telecom network simulation in full?** It models identity and segmented IT access. It does not model carrier signaling, radio/core networks, redundancy or production scale.

**What happens if a tool is blocked by Defender?** Record the prevention, retain logs and explain the affected test. Do not silently switch off protections and claim a realistic bypass.

**What are the weaknesses of this lab?** One DC, small identity population, no enterprise CA/SIEM deployment, no real workload baseline, incomplete endpoint collection and no Windows execution validation at publication.

## Five-minute demo once the lab is running

Show topology → DNS/domain health → one OU/group/SPN → one collected graph relationship → one bounded test and corresponding event → remediation and the identical retest. Show original evidence locally; use redacted screenshots in the repository. Do not attempt all advanced techniques in a rushed interview demo.

## Resume wording by evidence level

- **Now:** “Developed a reproducible AD security assessment lab package with PowerShell provisioning, segmentation policy, ATT&CK-mapped runbooks and evidence-based reporting templates.”
- **After deployment:** “Built and configured an isolated multi-VM AD lab with domain services, OUs, service identities, GPO logging and network segmentation.”
- **After validated exercises:** Name only the specific techniques completed, tool versions, observed boundary and remediation outcome. Avoid claiming unseen attacks or enterprise-scale validation.
