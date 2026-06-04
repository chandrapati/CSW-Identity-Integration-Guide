---
title: "CSW Identity Integration — Adoption Runbook"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Adoption runbook — from POV to production

A crawl → walk → run path to operationalise identity integration after a
successful POV. Each stage has an exit gate; don't advance until it's met.

## Stage 0 — Foundations

| Action | Exit gate |
|---|---|
| Decide authoritative directory & integrations | Documented in architecture |
| Stand up production connector runtime (appliances; redundant DC agents) | Healthy, redundant |
| Vault all service accounts / secrets / certs; set rotation | Rotation calendar live |
| Define label naming convention | Convention published |

## Stage 1 — Crawl: inventory only (no policy)

Goal: identity **visible** and trusted, changing nothing about
enforcement.

| Action | Exit gate |
|---|---|
| Enable catalog connectors (AD/OpenLDAP/Entra) | Users/groups/attributes accurate vs. directory |
| Enable live mapping (AD agent / Entra sign-ins) | IP→user accurate on sampled hosts |
| Reconcile username keys across sources (`sAMAccountName` / `displayName`) | Same human reconciles across sources |
| Stand up monitoring/alerting on connector & DC-agent health | Alerts firing on test failure |

**Exit:** stakeholders trust the identity data. No policy uses it yet.

## Stage 2 — Walk: labels in scopes & filters

Goal: identity **shapes structure** (scopes, filters, reporting) but not
yet enforced policy.

| Action | Exit gate |
|---|---|
| Build inventory filters on key identity labels | Filters match intent |
| Introduce identity into selected scopes | Scope membership stable & correct |
| Add user context to flow/dependency reviews | App owners can read flows by user/group |
| Review label→policy blast radius | Owners understand what a label change implies |

**Exit:** identity is part of how you *describe* the estate; no enforced
identity policy yet.

## Stage 3 — Run: identity in enforced policy

Goal: enforce on identity where supported, safely.

> Confirm enforcement granularity for your release with Cisco. Strongest
> on **Windows** OS-based user / user-group attributes.

| Action | Exit gate |
|---|---|
| Author identity policies in **monitor** mode | Predicted allow/deny reviewed & approved |
| Pilot enforcement on **one** low-risk app (Windows) | Allow/deny works; host-side proof captured |
| Expand app-by-app under change control | Each app: publish + enforce approved separately |
| Operationalise exceptions & break-glass | Documented, tested |

**Exit:** identity-aware enforcement live on the agreed scope, with
host-side proof and rollback paths.

## Operating model (steady state)

| Topic | Practice |
|---|---|
| Access reviews | AD group → label → policy is now an access path; include in periodic reviews |
| Change control | Adding an ingested attribute = adding a potential policy input → change-ticket it |
| Secret rotation | Entra client secret / bind passwords / DC service account on a schedule; certs preferred |
| Health monitoring | Connector status, DC-agent `Report Users`, sign-in-log ingest freshness |
| Drift | Watch for label coverage gaps (hosts with no user mapping) and stale mappings |
| Capacity | Watch inventory caps (~300k users / ~30k groups) and DC event-log volume |

## RACI (suggested)

| Activity | CSW/Security | AD / Identity team | App owners |
|---|---|---|---|
| Connector / DC-agent config | R/A | C | I |
| Service accounts & secrets | C | R/A | I |
| Label & scope design | R/A | C | C |
| Policy authoring & enforcement | R/A | I | C |
| Access reviews | C | R/A | C |

## Rollback

- **Connector:** disabling a connector removes its labels — model the
  impact on dependent scopes/policies first.
- **AD agent:** disabling **Report Users** stops new mappings; existing
  policy keyed on `user_*` labels degrades — plan accordingly.
- **Enforcement:** revert enforced policy to a previous version per the
  policy lifecycle; never leave a half-enforced identity policy in place.
