---
title: "Cisco Secure Workload — User Identity Reporting from a Domain Controller"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# User Identity Reporting from a Domain Controller (the "AD agent")

Install a Cisco Secure Workload **agent on a Domain Controller** and
enable **User Identity Reporting** so CSW maintains **live
IP-address-to-logged-in-user** mappings for **all** domain-joined
machines — including hosts that have no CSW agent of their own.

> Introduced in the **3.10.3.x** release train (release notes). Field
> names (`CswAgent` service, **Report Users** profile setting) are from
> Cisco documentation. **Confirm the exact privilege requirement for the
> service account against your release notes** before deploying — Cisco
> documents a domain-administrator Service Logon Account; scope to the
> minimum your security policy allows and validate it works.

---

## TL;DR

- **What it is.** A CSW Windows agent on a **Domain Controller** reads
  Windows **logon events** and reports **IP→user** for the whole domain.
- **Why it's powerful.** One (or a few, for redundancy) agent
  installations cover **every domain-joined machine** — no per-endpoint
  agent required for user attribution.
- **Three things to get right:**
  1. Agent installed on a DC.
  2. The **`CswAgent`** service runs under a **domain Service Logon
     Account** with rights to read domain logon events.
  3. **Report Users** enabled in the **Agent Configuration Profile**
     that targets the DC.
- **Plus:** domain **logon auditing** must be on, or there are no events
  to read.

---

## At a glance

```
   Domain-joined hosts (no CSW agent needed for user attribution)
        host-a (user alice)   host-b (user bob)   host-c (svc acct)
              │                     │                    │
              └──── domain logon events ────────────────┘
                              │
                  ┌───────────▼────────────┐
                  │   Domain Controller     │  CswAgent service runs as
                  │   + CSW Windows agent   │  a domain Service Logon Account
                  │   "Report Users" = on   │
                  └───────────┬─────────────┘
                              │  IP→user mappings
                              ▼
                    Cisco Secure Workload
                inventory carries logged-in-user context
```

---

## 1. Prerequisites

| Requirement | Detail |
|---|---|
| Host | A **Windows Domain Controller** (deploy on 2+ DCs for redundancy) |
| Agent | CSW **Windows agent** installed (see Agent Installation Guide) |
| Service account | A **domain Service Logon Account** for the `CswAgent` service with rights to read domain logon events. Cisco documents a *domain administrator* account; minimise to your policy and validate |
| Agent Config Profile | One that targets the DC with **Report Users** enabled |
| Logon auditing | Domain **logon-event auditing enabled** |
| Connectivity | Standard agent→cluster connectivity |

Full list: [`../docs/03-prerequisites.md`](../docs/03-prerequisites.md).
Service-account & audit checklist: [`examples/service-account-checklist.md`](./examples/service-account-checklist.md).

---

## 2. Install the agent on the Domain Controller

Follow the Windows agent install from the
[`CSW-Agent-Installation-Guide`](https://github.com/chandrapati/CSW-Agent-Installation-Guide)
(MSI silent install, CSW-generated PowerShell, SCCM, or Intune).

- Install in **visibility** first; this path is about reporting user
  mappings, not enforcing on the DC.
- Treat the DC as a sensitive host — change-control the install and
  validate stability before/after.

---

## 3. Run `CswAgent` under a domain Service Logon Account

The agent reports IP→user mappings for the domain **only when** the
`CswAgent` service runs under a **domain** account with rights to read
logon events (a local system context can't read domain-wide logons).

1. Create/identify the domain Service Logon Account (see the checklist).
2. Set the **`CswAgent`** service **Log On As** to that domain account
   (Services console, or per the Agent Installation Guide's
   "configured service user context" method — preferred so the installer
   sets it consistently).
3. Restart the service and confirm it starts cleanly under the new
   identity.

> Cisco's documentation calls for a **domain administrator** Service
> Logon Account. Domain Admin is broad — work with the AD team to
> determine the **least privilege** that still reads domain logon events
> in your environment, document the decision, and validate that user
> mappings still populate. Record the outcome as **"Confirm with Cisco"**
> in the evidence matrix until proven.

---

## 4. Enable "Report Users" in the Agent Configuration Profile

1. In CSW, open the **Agent Configuration Profile** applied to the DC
   (or create one targeting it).
2. Enable **Report Users**.
3. Save and let the profile apply to the DC's agent.

For how Agent Configuration Profiles target hosts, see *Create an Agent
Configuration Profile* in the User Guide and the Agent Installation
Guide.

---

## 5. Enable domain logon auditing

The agent reads Windows logon events; those must be generated:

- Ensure **Audit Logon Events** / **Audit Account Logon Events** is
  enabled via Group Policy on the domain controllers, so successful
  domain logons are recorded.
- Without auditing, the agent has nothing to read and no mappings
  appear.

---

## 6. Validation

1. From a domain-joined host **without** a CSW agent, log in as a known
   user.
2. In CSW **inventory**, confirm that host's IP now carries the
   logged-in-user context.
3. Repeat from a second host/user to confirm coverage is domain-wide,
   not just the DC.
4. Confirm mappings update as users log on/off (allow for the reporting
   interval).
5. Export evidence for the POV
   ([`../validation/02-evidence-matrix.md`](../validation/02-evidence-matrix.md)).

---

## 7. Troubleshooting (quick)

| Symptom | Likely cause | Action |
|---|---|---|
| No user mappings at all | `CswAgent` running as Local System, not the domain account | Set **Log On As** to the domain Service Logon Account; restart |
| Mappings for some hosts only | Logon auditing not enabled domain-wide; or logons go through other DCs | Enable auditing on all DCs; deploy the agent on additional DCs |
| Service won't start under new account | "Log on as a service" right missing | Grant the right via GPO/local policy; verify password |
| Mappings stale | Reporting interval / event volume | Allow for interval; confirm DC health and event-log sizing |
| Profile change not applied | Wrong Agent Config Profile scope | Confirm the profile with **Report Users** targets the DC |

Full flowcharts: [`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md).

---

## 8. Design notes

- **Redundancy:** deploy on **multiple DCs** so user attribution
  survives a single DC outage and covers logons authenticated by
  different DCs.
- **Security of the DC agent host:** the Service Logon Account is a
  high-value credential — vault it, rotate it, and monitor the
  `CswAgent` service. See
  [`../operations/02-security-hardening.md`](../operations/02-security-hardening.md).
- **Pairs with the AD catalog connector:** the agent gives live IP→user;
  the Identity Connector gives the group/attribute vocabulary. Use the
  same username key (`sAMAccountName`) so they reconcile.

---

## References

1. Cisco — *Release Notes 3.10.3.x — User Identity Reporting from Domain
   Controller* (Report Users; `CswAgent` Service Logon Account;
   IP→user for all domain-joined machines):
   <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/release-notes/3_10/cisco_secure_workload_release_notes_3_10_3_19.html>
2. Cisco — *Requirements and Prerequisites for Configuring Software
   Agents → Create an Agent Configuration Profile* (4.0 User Guide).
3. Cisco — *Verify Windows Agent in the Configured Service User Context*
   (4.0 User Guide) for setting the service logon identity at install.
