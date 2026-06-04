---
title: "Cisco Secure Workload — Microsoft Entra ID Connector"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Configure the Microsoft Entra ID connector

With the app registration in place
([`01-app-registration-graph-permissions.md`](./01-app-registration-graph-permissions.md)),
configure the Identity Connector for Entra ID in Secure Workload.

> Verified against the **CSW 4.0** *Microsoft Entra ID Connector →
> Configure Microsoft Entra ID* section.

---

## At a glance

```
                Cisco Secure Workload
                          ▲
                          │  users / groups / attributes → labels
                          │  (+ optional sign-in logs → IP→user)
                          │
              ┌───────────┴───────────┐
              │   Identity Connector  │  app-only auth (TenantID/ClientID/secret|cert)
              │  (Microsoft Entra ID) │
              └───────────┬───────────┘
                          │  HTTPS 443 → Microsoft Graph
                          ▼
                 Microsoft Entra ID
            App reg: cisco-secure-workload-identity
            Graph (Application): Directory/Group/User .Read.All [+AuditLog]
```

---

## 0. Before you start — fill these in

| Setting | Value |
|---|---|
| Target Secure Workload scope | _(decide locally)_ |
| Connector name | e.g. `entra-corp` |
| Domain name (unique in scope) | e.g. `csw.com` |
| TenantID | _(from app registration)_ |
| ClientID | _(from app registration)_ |
| Auth | Client Secret **or** Client Certificate + Key |
| Proxy required to reach Graph? | Yes / No |
| Attributes to ingest (≤6) | e.g. `department`, `jobTitle`, `mail` |

---

## 1. Configure the connector

*Source: CSW 4.0 Connectors guide, "Configure Microsoft Entra ID."*

1. **Manage → Workloads → Connectors**.
2. Click **Identity Connector** → **Configure your new connector here**.
3. On the **New Entra ID Connection** page, enter:

| Field | Value |
|---|---|
| **Connector Name** | e.g. `entra-corp` |
| **Description** | Free text |
| **Domain Name** | Unique in the selected scope (e.g. `csw.com`) |
| **TenantID** | Directory (tenant) ID from the app registration |
| **ClientID** | Application (client) ID from the app registration |
| **Client Secret** *or* **Client Certificate and Key** | From the app's Certificates & secrets. Certificate must be **unencrypted**, **RSA only**, key **PKCS1 or PKCS8** |
| **CA Certificate** | Upload CA cert + SSL server name; or **Disable SSL** (not recommended) |
| **Does your network require HTTP Proxy to reach IDENTITY?** | Yes/No; if yes, supply proxy details |
| **Secure Connector** | Enable if tunnelling via a deployed Secure Connector |

4. Click **Create**.

A new Identity Connector is created and communication between Secure
Workload and Entra ID is established.

---

## 2. Advanced settings

On **Advanced Settings**:

1. **Synchronize Schedule** — frequency CSW syncs user data from Entra ID.
2. **User Attributes** — up to **6** attributes to ingest (e.g.
   `department`, `jobTitle`, `mail`).
3. **Custom User Name Mapping** — map the username to **`displayName`**.

> In hybrid estates, align this with the AD connector's
> `sAMAccountName` mapping in your label/scope design so the same human
> reconciles across both sources.

---

## 3. Inventory & Event Log

- **Microsoft Entra ID Inventory** tab — Users and User Groups; filter
  by attributes; export **JSON/CSV**. Display limits ~**300,000 users**
  / ~**30,000 groups**.
- **Microsoft Entra ID Event Log** tab — Information (blue) / Warning
  (orange) / Error (red).

---

## 4. (Optional) Enable sign-in logs

For near-real-time **IP→user** mapping of cloud sign-ins, enable
sign-in logs during/after connector setup. This requires the
`AuditLog.Read.All` Graph permission. See
[`03-sign-in-logs-user-mapping.md`](./03-sign-in-logs-user-mapping.md).

---

## 5. Validation

1. Connector shows healthy on the **Connectors** page.
2. **Inventory** tab lists expected Entra users/groups; export evidence.
3. **Event Log** has no red entries.
4. Imported attributes appear as label dimensions on inventory.
5. If sign-in logs enabled: confirm recent sign-ins surface IP→user
   mappings (see `03`).

---

## 6. Troubleshooting (quick)

| Symptom | Likely cause | Action |
|---|---|---|
| `401/403` from Graph | Admin consent not granted; wrong permissions | Re-check the 4 Application permissions + **Grant admin consent** |
| Auth fails after weeks of working | **Client secret expired** | Rotate secret (or move to certificate); update connector |
| Connector can't reach Graph | Egress/proxy blocked | Allow HTTPS to Graph; set proxy in the connector |
| Certificate rejected | Encrypted key / non-RSA / wrong format | Provide **unencrypted**, **RSA**, **PKCS1/PKCS8** key |
| No sign-in mappings | `AuditLog.Read.All` missing or sign-in logs not enabled | Add permission + enable sign-in logs |

Full flowcharts: [`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md).

---

## References

1. Cisco — *Microsoft Entra ID Connector: Configure Microsoft Entra ID;
   Inventory; Event Log; Advanced Settings* (4.0):
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Cisco — *Microsoft Entra ID Connector (3.10)*:
   <https://securitydocs.cisco.com/docs/csw/3-10/user/93082.dita>
