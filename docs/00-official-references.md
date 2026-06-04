# Official Cisco references (read first)

This repository paraphrases and organises Cisco's documentation; it
does not replace it. Every factual claim about field names, limits,
permissions, and connector placement below is drawn from the pages in
this file. **When this guide and the User Guide disagree, the User
Guide wins.**

## Canonical pages

| Topic | Page |
|---|---|
| Configure and Manage Connectors — **On-Prem 4.0** | <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html> |
| Configure and Manage Connectors — **SaaS 4.0** | <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html> |
| Identity Connectors (3.10) | <https://securitydocs.cisco.com/docs/csw/3-10/user/93083.dita> |
| Microsoft Entra ID Connector (3.10) | <https://securitydocs.cisco.com/docs/csw/3-10/user/93082.dita> |
| Azure Connector Configuration Overview (3.10) | <https://securitydocs.cisco.com/docs/csw/3-10/user/91138.dita> |
| Configure External Authentication (admin login, 4.0) | <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-external-athentication.html> |
| Release Notes 3.10.3.x (User Identity Reporting from DC; Entra sign-in logs) | <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/release-notes/3_10/cisco_secure_workload_release_notes_3_10_3_19.html> |
| Virtual Appliances for Connectors (Edge / Ingest sizing) | On-Prem/SaaS 4.0 Connectors guide, *Virtual Appliances for Connectors* section |
| Secure Connector (tunnel to on-prem identity stores) | On-Prem/SaaS 4.0 Connectors guide, *Secure Connector* section |
| Policies Based on User Group or User Name (Windows) | On-Prem/SaaS 4.0 User Guide, *Enforce Policies with Agents → Configure Policies for Windows Attributes* |
| CSW 4.0 documentation landing page | <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/landing-page/secureworkload-40-docs.html> |
| CSW product home (Contact / demo / find a partner) | <https://www.cisco.com/c/en/us/products/security/secure-workload/index.html> |

## Which release introduced what

Confirm against **your** cluster's release notes — the table below is a
pointer, not a guarantee for your build.

| Capability | Documented in | Notes |
|---|---|---|
| Identity Connector (unified OpenLDAP / AD / Entra ID) | 3.10 / 4.0 Connectors guide | Replaces older per-source LDAP wiring; single "Identity Connector" entry under *Manage → Workloads → Connectors* |
| Active Directory via Identity Connector | 3.10 / 4.0 | Up to **15** user attributes; `sAMAccountName` username mapping |
| OpenLDAP via Identity Connector | 3.10 / 4.0 | OpenLDAP **2.6** supported; up to **6** attributes |
| Microsoft Entra ID Connector | 3.10 / 4.0 | Graph API app registration; up to **6** attributes; `displayName` mapping |
| Microsoft Entra ID **sign-in logs** (near-real-time IP→user) | 3.10.3.x release notes | Requires `AuditLog.Read.All`; enabled by an option during connector setup |
| **User Identity Reporting from Domain Controller** (AD agent) | 3.10.3.x release notes | Agent on a DC, `CswAgent` under a domain-admin Service Logon Account, **Report Users** in the Agent Configuration Profile |
| External Authentication LDAP + LDAP Authorization (`MemberOf`→role) | 3.9 / 4.0 External Authentication | Admin console login only — **not** a labelling connector |

## A note on terminology

Cisco has used several names over time. This repo standardises on the
current names and flags the legacy ones:

- **Cisco Secure Workload** = the product (formerly *Tetration*).
- **Microsoft Entra ID** = formerly *Azure Active Directory* / *Azure AD*.
- **Identity Connector** = the unified connector entry that fronts
  OpenLDAP, Active Directory, and Microsoft Entra ID identity sources.
- **CswAgent** = the Windows agent service (the AD-agent path runs this
  service on a Domain Controller).

> The `securitydocs.cisco.com/docs/csa/...` family of pages belongs to
> **Cisco Secure Access** — a *different* product. Do not use Secure
> Access "AD Connector" instructions for Secure Workload. The Secure
> Workload identity paths are the ones in this repo.
