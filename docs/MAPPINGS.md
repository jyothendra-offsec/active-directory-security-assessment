# ATT&CK and NIST alignment

These are analytical mappings, not certification or proof of execution. Technique coverage depends on what is actually observed.

| Activity | ATT&CK | Evidence required | Relevant NIST SP 800-53 Rev. 5 controls |
|---|---|---|---|
| Domain accounts/groups | T1087.002 / T1069.002 | Queries and returned lab objects | AC-2, AC-6, CA-8 |
| Kerberoasting | T1558.003 | Requested TGS; recovery separately evidenced | IA-5, AC-6, AU-6 |
| Password spraying | T1110.003 | Bounded attempts and correlated failures | AC-7, IA-5, SI-4 |
| Pass-the-Hash | T1550.002 | Known hash provenance plus target authentication | IA-5, AC-6, SC-7 |
| Golden Ticket | T1558.001 | Forged ticket acceptance, if manually executed | IA-5, IR-4, AU-6 |
| SMB lateral access | T1021.002 | Remote service access and authorization result | AC-6, SC-7, AU-12 |
| RDP, if added | T1021.001 | Remote interactive logon and session evidence | AC-17, SC-7 |

SP 800-115 informs planning, execution, analysis and mitigation reporting. SP 800-53 control identifiers help organize recommendations; they do not establish an organization's implementation or compliance. Do not label every group misconfiguration as an exploited privilege-escalation technique without observing the actual mechanism.
