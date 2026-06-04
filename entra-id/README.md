# "Entra AD" — Microsoft Entra ID Connector

This section covers integrating **Microsoft Entra ID** (formerly Azure
Active Directory) with Cisco Secure Workload via the **Identity
Connector**, using a **Microsoft Graph app registration**. It imports
the user/group catalog and — optionally — **sign-in (audit) logs** for
near-real-time **IP→user** mapping of cloud sign-ins.

| Doc | What it does |
|---|---|
| [`01-app-registration-graph-permissions.md`](./01-app-registration-graph-permissions.md) | Register the app in Entra ID and grant the Microsoft Graph **Application** permissions CSW needs |
| [`02-entra-id-connector.md`](./02-entra-id-connector.md) | Configure the Entra ID Identity Connector (TenantID / ClientID / secret-or-cert) |
| [`03-sign-in-logs-user-mapping.md`](./03-sign-in-logs-user-mapping.md) | Enable sign-in logs for near-real-time IP→user mapping (`AuditLog.Read.All`) |
| [`examples/`](./examples/) | `az` CLI helper to create the app registration and grant permissions |

## When to use this vs. the AD path

- **Entra ID is your identity source of truth** (cloud-first) → this
  section.
- **On-prem AD is authoritative** → use
  [`../active-directory/`](../active-directory/README.md), and add the
  **AD agent** ([`../ad-agent/`](../ad-agent/README.md)) for live
  on-prem IP→user.
- **Hybrid** → you may run both connectors; align the username key
  (`displayName` for Entra, `sAMAccountName` for AD) so labels reconcile.

## Read-only

The connector uses **Application** Graph permissions to **read**
directory data and (optionally) audit logs. It does not write to Entra
ID. Use a **client certificate** over a client secret where possible,
and vault either one.

## Key facts

- **Auth:** TenantID + ClientID + **Client Secret** *or* **Client
  Certificate + Key** (unencrypted, **RSA only**, key **PKCS1/PKCS8**).
- **Graph Application permissions:** `Directory.Read.All`,
  `GroupMember.Read.All`, `User.Read.All`; **`AuditLog.Read.All`** only
  if enabling sign-in logs. **All require admin consent.**
- **Attribute budget:** up to **6** attributes; username mapping →
  `displayName`.
