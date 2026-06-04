---
title: "CSW Identity Integration — Troubleshooting"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Troubleshooting

Symptom-first. Start with the connector/agent **Event Log** and health
status, then work outward to network, auth, and directory.

## Universal first checks

1. **Connector / agent health** on *Manage → Workloads → Connectors* (or
   the workload profile for the AD agent).
2. **Event Log tab** — Information (blue) / Warning (orange) / Error
   (red). Red is your starting point.
3. **Reachability** from the connector runtime to the source
   (LDAPS / Graph / agent→cluster).
4. **Time** — NTP skew breaks TLS and Kerberos and confuses log
   timelines.

## Identity Connector — AD / OpenLDAP

| Symptom | Likely cause | Action |
|---|---|---|
| Won't connect | Host/port wrong; firewall; TLS trust | Test 636 reachable from the appliance; verify CA cert + SSL server name |
| Connects, **no users** | User filter too narrow; wrong Base DN | Validate filter + Base DN with `ldapsearch`/ADSI (see AD examples) |
| Auth fails | Bind account locked/expired; MFA on the service account | Check account; ensure no interactive-MFA policy applies |
| Attributes missing | Not selected in Advanced Settings; empty in directory | Add to **User Attributes** (≤15 AD / ≤6 OpenLDAP); confirm populated |
| Username mismatch with AD-agent data | Mapping not aligned | Map AD to `sAMAccountName`; reconcile with live mapping |
| Heavy load on DC | Sync too frequent on large directory | Lengthen Synchronize Schedule; query a read-only DC / GC |
| OpenLDAP ingest errors | Unsupported server version | Confirm OpenLDAP **2.6** |

## Microsoft Entra ID connector

| Symptom | Likely cause | Action |
|---|---|---|
| `401/403` from Graph | Admin consent missing; wrong permission set | Re-add the 4 Application permissions; **Grant admin consent** |
| Worked, then broke after weeks | **Client secret expired** | Rotate (or switch to certificate); update connector |
| Certificate rejected | Encrypted key / non-RSA / wrong format | Provide **unencrypted**, **RSA**, **PKCS1/PKCS8** key |
| Can't reach Graph | Egress/proxy blocked | Allow HTTPS to Graph; configure proxy in connector |
| No sign-in (IP→user) mappings | `AuditLog.Read.All` missing; sign-in logs not enabled | Add permission + consent; enable sign-in logs |
| Sign-in mappings lag | Near-real-time ingestion latency | Allow for the ingestion window; verify recent sign-ins exist |

## AD agent (User Identity Reporting)

| Symptom | Likely cause | Action |
|---|---|---|
| **No** user mappings | `CswAgent` running as Local System | Set service **Log On As** to the domain Service Logon Account; restart |
| Mappings for some hosts only | Logon auditing off; logons via other DCs | Enable auditing on all DCs; deploy agent on additional DCs |
| Service won't start under new account | "Log on as a service" right missing | Grant via GPO/local policy; verify password |
| Mappings stale | Reporting interval; event-log churn | Allow for interval; size the DC security event log |
| Profile change ineffective | Wrong Agent Config Profile scope | Confirm the profile with **Report Users** targets the DC |

## External Authentication (admin login)

| Symptom | Likely cause | Action |
|---|---|---|
| Locked out after enabling LDAP | No local break-glass admin | Use the retained local Site Admin; if none, engage TAC |
| AD user can log in but has no access | LDAP Authorization off / no mapping | Enable LDAP Authorization; map `MemberOf`→role, or pre-assign roles |
| Wrong role/scope | Mapping points to wrong role/scope | Correct the `MemberOf`→role mapping |

## Escalation path

1. **Control plane** — connector/agent health + Event Log (this repo,
   `csw-api`).
2. **Network/auth** — reachability, TLS, service-account state.
3. **Directory** — filter/Base DN/attribute population (`ldapsearch`),
   Graph permissions/consent, domain logon auditing.
4. **Enforcement (if user policy)** — host-side proof with
   `csw-logs-check`.
5. **Cisco TAC** for cluster-side defects or release-specific behaviour.
