---
title: "Cisco Secure Workload — Entra ID App Registration & Graph Permissions"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Entra ID app registration and Microsoft Graph permissions

Before CSW can read Microsoft Entra ID, you register an application in
Entra ID and grant it the Microsoft Graph **Application** permissions
the connector uses.

> Verified against the **CSW 4.0** *Microsoft Entra ID Connector → Add
> Azure Permissions* section.

---

## TL;DR

- Create (or reuse) an **App Registration** in Entra ID.
- Grant these **Microsoft Graph → Application** permissions and **grant
  admin consent**:

| Permission | Type | Purpose |
|---|---|---|
| `Directory.Read.All` | Application | Read directory data |
| `GroupMember.Read.All` | Application | Read all group memberships |
| `User.Read.All` | Application | Read all users' full profile |
| `AuditLog.Read.All` | Application | **Only** if enabling **sign-in logs** |

- Create a **client secret** *or* (preferred) upload a **client
  certificate**. Record the **TenantID** and **ClientID**.

---

## 1. Register the application

In the **Azure portal** (Entra ID admin):

1. **Microsoft Entra ID → App registrations → New registration**.
2. Name it (e.g. `cisco-secure-workload-identity`), single-tenant is
   typical. Register.
3. From the app **Overview**, record:
   - **Application (client) ID** → CSW **ClientID**
   - **Directory (tenant) ID** → CSW **TenantID**

## 2. Add Graph API permissions

1. In the app, **Manage → API permissions**.
2. **Add a permission → Microsoft Graph → Application permissions**.
3. Add:
   - `Directory.Read.All`
   - `GroupMember.Read.All`
   - `User.Read.All`
   - `AuditLog.Read.All` — **only** if you will enable sign-in logs
     ([`03-sign-in-logs-user-mapping.md`](./03-sign-in-logs-user-mapping.md))
4. Click **Grant admin consent** for the tenant. All four are
   Application permissions and require admin consent — without consent
   the connector cannot read.

> Use **Application** permissions (app-only), not Delegated. The
> connector runs without a signed-in user.

## 3. Create credentials (secret or certificate)

Under **Manage → Certificates & secrets**:

**Option A — Client certificate (preferred):**
- Upload a certificate. Requirements for the matching private key you
  give CSW: **unencrypted**, **RSA only**, key format **PKCS1 or
  PKCS8**.
- Vault the private key; never commit it.

**Option B — Client secret:**
- **New client secret**; set an expiry aligned to your rotation policy.
- Copy the **secret value immediately** (it's shown once) and vault it.

> Prefer the **certificate** path: no plaintext secret to leak, and
> rotation is cleaner. If you must use a secret, set a short expiry and
> add a calendar reminder to rotate before it lapses (an expired secret
> silently breaks the connector — see
> [`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md)).

## 4. Record what CSW needs

| CSW connector field | Source |
|---|---|
| **TenantID** | App registration → Directory (tenant) ID |
| **ClientID** | App registration → Application (client) ID |
| **Client Secret** *or* **Client Certificate + Key** | Certificates & secrets |

Proceed to [`02-entra-id-connector.md`](./02-entra-id-connector.md).

## Automating the app registration

See [`examples/az-app-registration.sh`](./examples/az-app-registration.sh)
for an `az` CLI helper that creates the app, adds the Graph permissions,
and grants admin consent. It prints the Tenant/Client IDs and does **not**
write secrets to disk.

---

## References

1. Cisco — *Microsoft Entra ID Connector → Add Azure Permissions* (4.0):
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Microsoft — *Microsoft Graph permissions reference*:
   <https://learn.microsoft.com/graph/permissions-reference>
3. Microsoft — *Register an application with the Microsoft identity
   platform*:
   <https://learn.microsoft.com/entra/identity-platform/quickstart-register-app>
