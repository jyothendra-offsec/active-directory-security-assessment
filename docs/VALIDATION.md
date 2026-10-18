# Validation boundary

This repository was authored in a Linux environment without Windows VMs, AD DS, VirtualBox, native PowerShell or nftables. It is a deployment and assessment package, not a completed penetration-test report.

## Checks performed

- JSON topology: unique addresses, expected domain, subnet/gateway consistency.
- Local Markdown links and CSV record shapes.
- Execution ledger contains no claimed completed experiments.
- Original PNG/SVG diagrams rendered and visually reviewed.
- PowerShell parsed with the optional tree-sitter grammar; this is not Microsoft's parser and does not validate cmdlet availability or execution semantics.

Run `python tests/validate_static.py` from the project root. Optional grammar dependencies are `tree-sitter` and `tree-sitter-powershell`. See `tests/validation-output.txt` for the recorded output.

## Required next validation

1. On FW01, run `nft -c -f config/router.nft` before loading the rules.
2. In Windows PowerShell 5.1, parse the scripts using `System.Management.Automation.Language.Parser`, then execute the documented build order on disposable VMs.
3. Verify DNS, time, domain join, GPO application, effective auditing and router policy.
4. Execute each authorized exercise and retain evidence. Golden Ticket is an optional manual assessment plan, not implemented automation.
5. Update the ledger and publish redacted findings only after reviewing real results.

No Windows deployment, successful attack, detection rate, remediation success or production compatibility is asserted. Tool/OS compatibility remains to be established with the exact versions used in the lab.
