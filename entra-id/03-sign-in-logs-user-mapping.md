---
title: "Cisco Secure Workload — Entra ID Sign-in Logs (IP→user mapping)"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Entra ID sign-in logs — near-real-time IP→user mapping

The Entra ID connector can ingest **sign-in (audit) logs** to provide
**near-real-time IP-address-to-user mappings** for cloud sign-ins. This
is the cloud equivalent of the on-prem **AD agent** path.

> Introduced/updated in the **3.10.3.x** release train (release notes).
> Confirm availability in your cluster's release notes.

---

## What it gives you

- The connector's catalog import tells you *who exists*.
- **Sign-in logs** add *who signed in from which IP, recently* — so CSW
  inventory can carry up-to-date user context derived from Entra ID
  sign-in events.
- Result: improved accuracy of user identity details in inventory from
  near-real-time ingestion of IP→user mappings.

## Prerequisite — the extra Graph permission

Enabling sign-in logs requires the Microsoft Graph **Application**
permission:

| Permission | Type | Why |
|---|---|---|
| `AuditLog.Read.All` | Application | Read all audit (incl. sign-in) log data |

Add it to the app registration and **grant admin consent** (see
[`01-app-registration-graph-permissions.md`](./01-app-registration-graph-permissions.md)).
The other three permissions (`Directory.Read.All`,
`GroupMember.Read.All`, `User.Read.All`) remain required for the catalog.

## Enable it

- During Entra ID connector setup, enable the **sign-in logs** option.
  (If the connector already exists, edit it and enable the option, then
  ensure `AuditLog.Read.All` is consented.)

## Validation

1. Generate a known Entra ID sign-in (or use a recent one).
2. In CSW inventory, confirm the signing user's context appears against
   the expected IP within the ingestion window.
3. Export evidence (JSON/CSV) for the POV
   ([`../validation/02-evidence-matrix.md`](../validation/02-evidence-matrix.md)).

## Caveats

- Sign-in logs reflect **Entra ID sign-in events** — coverage depends on
  what authenticates through Entra ID. On-prem-only logons that never
  touch Entra ID won't appear here; use the **AD agent**
  ([`../ad-agent/`](../ad-agent/README.md)) for those.
- There is an **ingestion latency** (near-real-time, not instant); set
  expectations in the POV test plan.
- Hybrid identity: a user may appear via both Entra sign-in logs and the
  AD agent — reconcile on a consistent username key in your label design.

---

## References

1. Cisco — *Release Notes 3.10.3.x* (Microsoft Entra ID sign-in logs;
   User Identity Reporting from Domain Controller):
   <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/release-notes/3_10/cisco_secure_workload_release_notes_3_10_3_19.html>
2. Cisco — *Microsoft Entra ID Connector* (4.0 Connectors guide).
