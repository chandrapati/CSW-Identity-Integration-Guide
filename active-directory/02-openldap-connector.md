---
title: "Cisco Secure Workload — Identity Connector for OpenLDAP"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Identity Connector for OpenLDAP

Import users and user groups from an **OpenLDAP** directory into Cisco
Secure Workload using the **Identity Connector**. Same connector family
as the AD path; a few differences in attribute budget and version
support.

> Verified against the **CSW 4.0 On-Prem / SaaS** *Configure and Manage
> Connectors → Identity Connectors → OpenLDAP* section.

---

## TL;DR

- **Supported version:** OpenLDAP **2.6** for data ingestion.
- **Attribute budget:** up to **6** user attributes (AD allows 15).
- **Read-only**, scheduled pull; never writes to LDAP.
- Same placement options: CSW appliance, optionally via **Secure
  Connector** tunnel.

---

## 1. Prerequisites

| Requirement | Detail |
|---|---|
| OpenLDAP | Version **2.6** |
| CSW login | Site Admin or scope owner |
| Connector runtime | Secure Workload virtual appliance |
| Reachability | CSW → LDAP **636 (LDAPS)** / 389; or **Secure Connector** |
| Bind account | Dedicated **read-only** LDAP account |
| Base DN | e.g. `dc=csw,dc=com` |
| User filter | e.g. `(&(objectClass=person)(objectClass=user))` |
| TLS | CA certificate for LDAPS (recommended) |

---

## 2. Configure the Identity Connector for OpenLDAP

*Source: CSW 4.0 Connectors guide, "Configure Identity Connector with
OpenLDAP."*

1. **Manage → Workloads → Connectors**.
2. Click **Identity Connector** → **Configure your new connector here**.
3. On the **New Connection** page, enter:

| Field | Value |
|---|---|
| **Connector Name** | A name for the connector |
| **Description** | Free text |
| **Domain Name** | Unique in the selected scope (e.g. `csw.com`) |
| **Base DN** | e.g. `dc=csw,dc=com` |
| **User Filter** | LDAP filter selecting users |
| **Username and Password** | Read-only bind account |
| **CA Certificate** | Upload CA cert + SSL server name; or **Disable SSL** (not recommended) |
| **Server IP/FQDN and Port** | e.g. `ldap01.csw.com` / `636` |
| **Secure Connector** | Enable if tunnelling via a deployed Secure Connector |

4. Click **Create**.

---

## 3. Advanced settings

On **Advanced Settings**:

1. **Synchronize Schedule** — frequency CSW syncs user data from LDAP.
2. **User Attributes** — up to **6** attributes to display/ingest.

---

## 4. Inventory & Event Log

- **Inventory tab** — Users and User Groups; export JSON/CSV. Recommended
  display limits ~**300,000 users** / ~**30,000 groups**.
- **Event Log tab** — Information (blue) / Warning (orange) / Error (red).

---

## 5. Validation & troubleshooting

Same approach as the AD path — see
[`01-identity-connector-ad.md`](./01-identity-connector-ad.md) §7–§8 and
[`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md).
Key OpenLDAP-specific checks:

| Symptom | Action |
|---|---|
| Ingestion errors on a newer/older server | Confirm server is OpenLDAP **2.6** |
| Need >6 attributes | Not supported on OpenLDAP — prioritise the 6 that matter, or evaluate AD path |

---

## References

1. Cisco — *Configure and Manage Connectors: Identity Connectors →
   OpenLDAP Connector; Advanced Settings; Inventory; Event Log* (4.0).
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
