# Scope and handling
Run only on personally controlled disposable VMs in the documented 10.77.0.0/16 lab. Written scope, exact hosts, allowed techniques, start/end times and stop conditions belong in the execution ledger. Do not connect the lab to an employer, university, VPN or production identity system.

Use VM consoles for changes that may interrupt networking. Install updates/tools before isolation, disconnect temporary internet adapters, and verify the absence of a default route to an external gateway. Do not disable endpoint protection to make a technique work; record a prevention result.

Stop on unexpected external traffic, non-lab identities, lockouts, instability or missing logs. Do not use real passwords. Store test secrets in a local password manager; never paste them into GitHub issues or commit history. Restore coordinated offline VM snapshots for reset, not individual DC snapshots in a running environment. These reset instructions apply only to this disposable single-DC forest.
