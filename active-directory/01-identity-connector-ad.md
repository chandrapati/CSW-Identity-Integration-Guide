---
title: "Cisco Secure Workload — Identity Connector for Active Directory"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Identity Connector for Active Directory

Import the **Active Directory** user and user-group catalog into Cisco
Secure Workload as identity labels and inventory, using the **Identity
Connector**. This is the integration most people mean by "the CSW AD
connector."

> Verified against the **CSW 4.0 On-Prem / SaaS** *Configure and Manage
> Connectors → Identity Connectors → Active Directory* sections. Field
> names and limits below are from that documentation. Confirm
> release-specific behaviour in your User Guide.

---

## TL;DR — 60-second read

- **What it is.** A built-in **Identity Connector** that binds to AD,
  reads **users, user groups, and up to 15 attributes**, and makes them
  available as labels / inventory in Secure Workload. **Read-only** on
  Cisco's side — CSW pulls from AD and never writes back.
- **Where it runs.** As a connector reachable from CSW; on-prem AD that
  isn't directly reachable uses the **Secure Connector** tunnel or an
  **HTTP proxy**.
- **What you need in AD.** A **dedicated read-only bind account**, the
  **Base DN**, and a **user filter**. No write, no domain admin.
- **Username mapping.** Map the CSW username to **`sAMAccountName`** in
  Advanced Settings.
- **Scale.** Recommended display limits ~**300,000 users** /
  ~**30,000 user groups**.
- **What it does *not* do.** It does not tell you which IP a user is on
  *right now* — that's the **AD agent** ([`../ad-agent/`](../ad-agent/README.md))
  for on-prem or **Entra sign-in logs** for cloud.

---

## At a glance

```
                Cisco Secure Workload
                          ▲
                          │  user/group catalog + attributes
                          │  become labels / inventory
                          │
              ┌───────────┴───────────┐
              │   Identity Connector  │  read-only LDAP bind, scheduled sync
              │  (on a CSW appliance) │
              └───────────┬───────────┘
                          │  LDAPS 636 (preferred) · Base DN + user filter
                          │  optional Secure Connector tunnel / HTTP proxy
                          ▼
                  Active Directory
            bind acct: svc_csw_identity (read-only)
```

---

## 0. Before you start — fill these in

| Setting | Value to use |
|---|---|
| Target Secure Workload scope | _(decide locally)_ |
| Connector name | e.g. `ad-corp` |
| Domain name (unique in scope) | e.g. `csw.com` |
| Base DN | e.g. `dc=csw,dc=com` |
| AD server IP / FQDN + port | e.g. `dc01.csw.com:636` |
| Bind account | e.g. `svc_csw_identity` (read-only) |
| LDAPS CA certificate | _(from your PKI)_ |
| Reachability | Direct · Secure Connector · HTTP proxy |
| Attributes to ingest (≤15) | e.g. `department`, `title`, `memberOf`, `mail`, `manager` |

---

## 1. What this integration does

- The Identity Connector performs a **read-only bind** to Active
  Directory and **discovers** the directory schema.
- It imports **users** and **user groups** matching your **user
  filter**, with up to **15 user attributes** per user.
- All the user groups a user belongs to appear on the **Users** tab;
  unique groups appear on the **User Groups** tab.
- Imported attributes become **labels** usable in inventory filters,
  scopes, and (where supported) policy.
- Data refreshes on the **Synchronize Schedule** you set.

What this is **not**:

- Not a write integration — CSW never modifies AD.
- Not a live IP→user mapping — use the **AD agent** for that.
- Not admin login — that's **External Authentication**
  ([`03-external-auth-ldap-rbac.md`](./03-external-auth-ldap-rbac.md)).

---

## 2. Prerequisites

| Requirement | Detail |
|---|---|
| CSW login | Site Admin or scope owner |
| Connector runtime | Secure Workload virtual appliance for the Identity Connector |
| Reachability | CSW → AD on **636 (LDAPS)** / 389; or **Secure Connector** / **HTTP proxy** |
| Bind account | Dedicated **read-only** domain user; no write/admin |
| Base DN | e.g. `dc=csw,dc=com` |
| User filter | e.g. `(&(objectClass=person)(objectClass=user))` |
| TLS | CA certificate for LDAPS (recommended); SSL can be disabled but **don't** in production |

Full list: [`../docs/03-prerequisites.md`](../docs/03-prerequisites.md).

---

## 3. Create the read-only bind account (in AD)

1. Create a **dedicated** service account, e.g. `svc_csw_identity`.
2. Grant **read** access to the user/group OUs in scope — nothing more.
   Do **not** grant Domain Admin or any write right.
3. Set a long random password (≥24 chars); store it in your vault.
4. (Recommended) Restrict the account by **source IP** to the
   connector/appliance egress, and exclude it from interactive logon.

> The connector only needs to **read** users and groups. If someone
> proposes Domain Admin "to be safe," push back — least privilege is
> the whole point of a dedicated bind account.

---

## 4. Configure the Identity Connector for AD

*Source: CSW 4.0 Connectors guide, "Configure Active Directory with
Identity Connector."*

1. From the navigation pane, choose **Manage → Workloads → Connectors**.
2. Choose **Identity Connector** and click **Configure your new
   connector here**.
3. On the **New AD Connection** page, enter:

| Field | Value |
|---|---|
| **Connector Name** | A name for the connector (e.g. `ad-corp`) |
| **Description** | Free text |
| **Domain Name** | Unique in the selected scope (e.g. `csw.com`) |
| **Base DN** | Search starting point (e.g. `dc=csw,dc=com`) |
| **User Filter** | LDAP filter selecting users (see §6) |
| **Username and Password** | The read-only bind account credentials |
| **CA Certificate** | Upload the CA cert + SSL server name for LDAPS; or **Disable SSL** (not recommended) |
| **Server IP/FQDN and Port** | e.g. `dc01.csw.com` / `636` |
| **Does your network require HTTP Proxy to reach IDENTITY?** | If yes, enter proxy URL + port |
| **Secure Connector** | Enable if tunnelling from CSW to AD via a deployed Secure Connector |

4. Click **Create**.

A new Identity Connector is created and communication between Secure
Workload and Active Directory is established.

---

## 5. Advanced settings (attributes, sync, username mapping)

On the connector's **Advanced Settings** tab:

1. **Synchronize Schedule** — choose how often CSW syncs user data from
   AD. Start conservative (e.g. daily) for large directories; tighten if
   freshness matters and the directory can handle the query load.
2. **User Attributes** — enter **up to 15** AD attributes to ingest
   (e.g. `department`, `title`, `memberOf`, `mail`, `manager`,
   `physicalDeliveryOfficeName`). Each becomes a label dimension.
3. **Custom User Name Mapping** — map the username to **`sAMAccountName`**.
   This is the field that lines up with logon names from the AD-agent
   path, so set it consistently across integrations.

> **Attribute budget is a design decision, not a dumping ground.**
> Every attribute you ingest becomes a label that can end up in policy.
> Pick the 5–10 attributes that map to how you actually segment
> (department, group, environment, data-classification) rather than
> ingesting the full schema.

---

## 6. User filter cookbook

| Goal | Filter |
|---|---|
| All AD users | `(&(objectClass=person)(objectClass=user))` |
| Users excluding disabled accounts | `(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))` |
| Members of a specific group (by DN) | `(&(objectClass=user)(memberOf=CN=PCI-Admins,OU=Groups,DC=csw,DC=com))` |
| Users in a department | `(&(objectClass=user)(department=Finance))` |
| Users whose CN contains "Marketing" | `(&(objectClass=user)(cn=*Marketing*))` |

More in [`examples/ldap-filters.md`](./examples/ldap-filters.md).

---

## 7. Validation

1. **Connectors page** — the Identity Connector shows healthy / enabled.
2. **Inventory tab** of the connector — under **Users and Groups**,
   enter attributes to filter and click **Search Inventory**. Confirm
   expected users and groups appear. Use the menu icon to export
   **JSON / CSV** as POV evidence.
3. **Event Log tab** — confirm no red (error) entries; colour codes are
   Information (blue), Warning (orange), Error (red).
4. **Label search** — confirm the imported attributes appear as label
   dimensions and resolve on real inventory.
5. Capture evidence per [`../validation/02-evidence-matrix.md`](../validation/02-evidence-matrix.md).

---

## 8. Troubleshooting (quick)

| Symptom | Likely cause | Action |
|---|---|---|
| Connector won't connect | Wrong host/port, TLS trust, firewall | Verify 636 reachable; confirm CA cert + SSL server name; test bind from the appliance |
| Binds but no users | User filter too narrow / wrong Base DN | Loosen filter; verify Base DN against `dsquery`/ADSI |
| Auth fails | Bind account locked / bad password / MFA on account | Check account status; ensure no interactive-MFA policy applies to the service account |
| Attributes missing | Not selected in Advanced Settings, or empty in AD | Add to **User Attributes**; confirm populated in AD |
| Slow / heavy on DC | Sync too frequent on a large directory | Lengthen the Synchronize Schedule; consider querying a read-only DC / GC |

Full flowcharts: [`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md).

---

## 9. Open questions to confirm in your environment

1. Which **scope** does the AD identity data land in?
2. Which **OUs** and **user filter** define the in-scope population?
3. Which **≤15 attributes** map to how you segment?
4. Direct, **Secure Connector**, or **proxy** reachability to the DC?
5. Where is the **bind-account password** vaulted, and on what rotation?
6. Is `sAMAccountName` the right username key to align with the AD-agent
   live mapping?

---

## References

1. Cisco — *Cisco Secure Workload User Guide (On-Prem/SaaS 4.0) —
   Configure and Manage Connectors: Identity Connectors → Active
   Directory; Advanced Settings; Inventory; Event Log.*
   [On-Prem 4.0](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS 4.0](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Cisco — *Identity Connectors (3.10).*
   <https://securitydocs.cisco.com/docs/csw/3-10/user/93083.dita>
3. Cisco — *Virtual Appliances for Connectors* and *Secure Connector*
   (same Connectors guide) for connector runtime and tunnelling.
