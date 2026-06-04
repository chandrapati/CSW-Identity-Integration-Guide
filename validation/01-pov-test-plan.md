---
title: "CSW Identity Integration — POV Test Plan"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# POV test plan — identity integration

A phased plan to prove identity integration value in a proof-of-value.
Pick the integrations in scope (one or more of AD, OpenLDAP, Entra ID,
AD agent) and run the matching tests. Record results in
[`02-evidence-matrix.md`](./02-evidence-matrix.md).

## Scoping (do this first)

| Question | Decision |
|---|---|
| Which directory is authoritative? | AD / OpenLDAP / Entra ID / hybrid |
| Need live IP→user on-prem? | Yes → AD agent |
| Need live IP→user in cloud? | Yes → Entra sign-in logs |
| Need admin login via AD? | Yes → External Authentication |
| Target scope for identity labels | _(name)_ |
| Enforcement on identity in scope? | Yes/No → if yes, mark "Confirm with Cisco" until proven |

## Phase 0 — Prerequisites & access

- [ ] Appliance / app registration / service accounts ready
      ([`../docs/03-prerequisites.md`](../docs/03-prerequisites.md)).
- [ ] Reachability confirmed (LDAPS / Graph / Secure Connector / proxy).
- [ ] Secrets vaulted; least-privilege accounts created.
- **Pass:** all prerequisites green before touching the connector UI.

## Phase 1 — Connect

Run only the rows for in-scope integrations.

| Integration | Step | Pass criteria |
|---|---|---|
| AD | Create Identity Connector → AD | Connector healthy; Event Log no errors |
| OpenLDAP | Create Identity Connector → OpenLDAP | Connector healthy; Event Log no errors |
| Entra ID | Create Entra ID connector | Connector healthy; Graph auth OK |
| AD agent | Agent on DC + Report Users | Service runs as domain account; profile applied |
| External Auth | Enable LDAP + keep break-glass | Test AD login works; local admin retained |

## Phase 2 — Inventory (catalog)

| Test | Pass |
|---|---|
| Users imported | Expected users visible in connector Inventory tab |
| Groups imported | Expected user groups visible |
| Attributes imported | Chosen attributes present (≤15 AD / ≤6 OpenLDAP/Entra) |
| Username mapping | `sAMAccountName` (AD) / `displayName` (Entra) resolves correctly |
| Export | JSON/CSV exported as evidence |

## Phase 3 — Live IP→user mapping (if in scope)

| Path | Test | Pass |
|---|---|---|
| AD agent | Log in on an **agentless** domain host as a known user | That host's IP carries the user in CSW inventory |
| AD agent | Log in from a host authenticated by a 2nd DC | Mapping appears (domain-wide coverage) |
| Entra sign-in | Perform a known Entra sign-in | IP→user mapping appears within ingestion window |

## Phase 4 — Labels in scopes & filters

| Test | Pass |
|---|---|
| Inventory filter on a group/attribute label | Filter returns the expected workloads |
| Scope using an identity label | Scope membership matches intent |
| Dependency / flow view filtered by user context | Flows attributable to user/group |

See [`03-user-based-policy-examples.md`](./03-user-based-policy-examples.md).

## Phase 5 — Identity in policy (optional, enforcement)

> Validate enforcement granularity for the customer's release with the
> Cisco account/BU team **before** committing. Strongest on **Windows**
> via OS-based user / user-group attributes.

| Test | Pass |
|---|---|
| Author a policy referencing a user-group label (monitor mode) | Policy analyses as intended (predicted allow/deny correct) |
| Windows OS-based user/user-group policy on a test host | Allowed user flow works; disallowed user flow blocked **after** publish/enforce + cutoff |
| Host-side proof | Rule present on host; timing validated (use `csw-logs-check`) |

**Never** bundle publish + enable-enforce; treat each as customer
change-control with explicit approval.

## Phase 6 — Hand-off

- [ ] Evidence matrix complete with scores + artifact links.
- [ ] Open items / "Confirm with Cisco" list updated.
- [ ] Adoption plan drafted ([`04-adoption-runbook.md`](./04-adoption-runbook.md)).

## Scoring model

| Status | Meaning |
|---|---|
| **Pass** | Demonstrated with artifact captured |
| **Pass — design validated** | Supported per docs/design; not fully deployed in POV |
| **Partial** | Works with constraints / platform limits |
| **Not tested** | In scope later |
| **Confirm with Cisco** | Needs release/BU confirmation before final score |
