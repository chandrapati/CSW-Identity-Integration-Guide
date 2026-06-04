# Concepts — identity in Cisco Secure Workload

Read this before configuring anything. The single most common source of
confusion in this space is conflating two unrelated uses of "AD" in CSW.

## The two meanings of "identity" in CSW

| | **Identity for labels / policy** | **Identity for admin login** |
|---|---|---|
| Question it answers | "Which *user / group* is associated with this workload or flow?" | "Can *this operator* log into the CSW console, and with what role?" |
| Mechanism | **Identity Connector** (AD / OpenLDAP / Entra ID) + **User Identity Reporting** (AD agent) | **External Authentication** (LDAP/SSO) + LDAP Authorization |
| Output | **Labels** on inventory IPs; user / user-group inventory | A logged-in CSW session mapped to a CSW **role** |
| Covered in | [`active-directory/`](../active-directory/README.md), [`entra-id/`](../entra-id/README.md), [`ad-agent/`](../ad-agent/README.md) | [`active-directory/03-external-auth-ldap-rbac.md`](../active-directory/03-external-auth-ldap-rbac.md) |

This repo is primarily about the **left column** — identity for labels
and policy. The right column is included for completeness because
customers routinely ask for both in the same breath.

## The three label/policy paths and how they differ

```
                       ┌───────────────────────────────────────────────┐
                       │            Cisco Secure Workload               │
                       │   Inventory  ·  Labels  ·  Scopes  ·  Policy   │
                       └───────▲───────────────▲──────────────▲─────────┘
                               │               │              │
        user/group catalog     │  IP→user      │  IP→user     │  user/group
        (who exists)           │  (cloud)      │  (on-prem)   │  catalog
                               │               │              │
                ┌──────────────┴──┐   ┌────────┴────────┐  ┌──┴───────────────┐
                │ Identity Conn.  │   │  Entra ID conn. │  │ User Identity     │
                │  → AD / LDAP    │   │  sign-in logs   │  │ Reporting (agent  │
                │  (catalog pull) │   │  (Graph)        │  │ on a DC)          │
                └──────────────▲──┘   └────────▲────────┘  └──▲───────────────┘
                               │               │              │
                        ┌──────┴─────┐   ┌─────┴─────┐  ┌─────┴──────────────┐
                        │ AD / LDAP  │   │ Entra ID  │  │ Domain Controller   │
                        │ directory  │   │ (Graph)   │  │ (Windows logon evts)│
                        └────────────┘   └───────────┘  └─────────────────────┘
```

### 1. Identity Connector → Active Directory / OpenLDAP — *the catalog*

- **Pulls the directory catalog**: which **users** and **user groups**
  exist, plus selected attributes (department, title, group membership…).
- Gives you the vocabulary to *design* identity-aware scopes and
  filters and to enrich inventory.
- It does **not**, by itself, tell you *which IP a user is on right
  now* — that is the job of the Entra sign-in logs (cloud) or the AD
  agent (on-prem).
- Runs as a connector reachable from CSW; on-prem directories that
  aren't directly reachable use the **Secure Connector** tunnel.

### 2. Microsoft Entra ID connector — *cloud catalog + cloud sign-ins*

- Same catalog import as above (users / groups / attributes via
  Microsoft Graph).
- **Plus** an optional **sign-in (audit) log** ingest that provides
  **near-real-time IP→user** mappings for cloud sign-ins
  (requires `AuditLog.Read.All`).
- The right choice when Entra ID is the primary identity source and
  you want cloud sign-in context.

### 3. User Identity Reporting (AD agent) — *live on-prem IP→user*

- A CSW **agent installed on a Domain Controller** (not on every
  endpoint) reads Windows **logon events** and reports **IP→logged-in
  user** for **all** domain-joined machines — even those without a CSW
  agent.
- The strongest path for live "who is on this host" on-prem.
- Depends on the host-agent foundation (see
  [`CSW-Agent-Installation-Guide`](https://github.com/chandrapati/CSW-Agent-Installation-Guide)).

## What you can do with identity once it's in CSW

| Capability | Reality today | Where |
|---|---|---|
| **Enrich inventory** with user / group / attribute labels | Yes — all paths | Inventory & label search |
| **Design scopes & inventory filters** on identity labels | Yes | [`validation/03-user-based-policy-examples.md`](../validation/03-user-based-policy-examples.md) |
| **Investigate flows** by user context | Yes (where IP→user mapping exists) | Flow / forensic search |
| **Enforce policy on user / user-group** | **Windows agents** support user / user-group OS-based policy — **confirm scope for your release** | [`docs/02-decision-matrix.md`](./02-decision-matrix.md) |
| **Forensic events** referencing users (e.g. *User Log on Failed*) | Yes (agent forensics) | Forensic rules |

> **Set expectations early in a POV.** Identity *visibility and
> labelling* is broadly available across all paths. Identity *in
> enforced policy* is platform- and release-specific (strongest on
> Windows with OS-based attributes). Always validate the exact
> enforcement granularity with the Cisco BU/account team for the
> customer's release — mark it **"Confirm with Cisco"** in the
> evidence matrix until proven in the POV.

## Read-only, always

Every path in this repo **reads** from the identity source. None of
them create, modify, or delete users, groups, or attributes in AD,
OpenLDAP, or Entra ID. The AD-agent path reads Windows **logon events**;
it does not change directory state. Treat the service accounts as
high-value read credentials and vault them
([`operations/02-security-hardening.md`](../operations/02-security-hardening.md)).
