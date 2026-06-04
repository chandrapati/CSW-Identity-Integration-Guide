---
title: "CSW Identity Integration — Identity in Scopes, Filters & Policy"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Identity in scopes, filters, and policy

Worked examples of turning imported identity labels into **scopes**,
**inventory filters**, and (where supported) **policy**. The label
names below are illustrative — your actual label keys come from the
attributes you chose to ingest.

## From attribute to label

When you ingest an AD attribute (e.g. `department`) or a user-group, it
becomes a **label dimension** on inventory. Live IP→user mapping (AD
agent / Entra sign-in logs) is what binds that label to a current
workload IP.

| Source attribute | Example label key | Example values |
|---|---|---|
| `department` | `user_department` | `Finance`, `Engineering`, `Contractors` |
| `memberOf` / group | `user_group` | `PCI-Admins`, `HR`, `DBA` |
| `jobTitle` (Entra) | `user_title` | `DBA`, `SRE` |
| logged-in user (AD agent) | `user_name` | `alice`, `bob` |

> Exact label naming depends on connector configuration and your label
> conventions. Confirm the resolved key names in **label search** before
> writing queries.

## Inventory filters on identity

Filter examples (conceptual query form — build them in the inventory
filter UI):

| Intent | Filter |
|---|---|
| All workloads currently used by Contractors | `user_department = Contractors` |
| Hosts with a PCI-Admin logged in | `user_group = PCI-Admins` |
| Finance department workstations | `user_department = Finance` |

Use these to validate coverage (ID-11 in the evidence matrix) and as
building blocks for scopes.

## Scopes on identity

Build a scope whose query includes an identity label so membership
follows the directory, not a static IP list:

```
Scope: Root:Corp:Contractors
Query: user_department = Contractors
```

Combine with network/location labels for precision:

```
Scope: Root:PCI:PrivilegedAccess
Query: (user_group = PCI-Admins) AND (environment = PCI)
```

## Policy on identity (where supported)

> **Enforcement reality check:** user / user-group **enforcement** is
> strongest on **Windows** agents via OS-based filtering attributes
> (*Policies Based on User Group or User Name*). Validate granularity
> for the customer's release with Cisco before promising it. Always
> model in **monitor** mode first.

Illustrative intents (author in a workspace, analyse in monitor mode,
then publish/enforce under change control):

| Intent | Consumer | Provider | Action |
|---|---|---|---|
| Block contractors from PCI app | `user_department = Contractors` | `app = PCI-App` | Deny |
| Allow DBAs to database tier | `user_group = DBA` | `tier = Database` | Allow |
| Restrict admin tooling to PCI-Admins | `user_group = PCI-Admins` | `app = AdminTooling` | Allow (deny others via catch-all) |

### Safe sequence

```
author policy → analyse in MONITOR (predicted allow/deny)
→ review impact with app owners → publish analyzed version
→ enable enforce (one app) → functional allow/deny test
→ host-side proof (csw-logs-check) → document
```

- Treat **publish** and **enable-enforce** as separate change-control
  approvals.
- For Windows OS-based user policy, verify the rule lands on the host and
  validate the **cutoff timestamp** with `csw-logs-check` — don't trust
  control-plane state alone.

## Validation hooks

- Inventory filter returns expected workloads → evidence ID-11.
- Scope membership matches intent → evidence ID-12.
- Monitor-mode policy predicts correct allow/deny → evidence ID-14.
- Windows enforcement allow/deny + host proof → evidence ID-15
  (**Confirm with Cisco** until demonstrated).
