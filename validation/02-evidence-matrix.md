---
title: "CSW Identity Integration — Evidence Matrix"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Evidence matrix (copy & fill per engagement)

One row per requirement. Fill **Status** and **Evidence** as you go.
Keep customer-specific copies in the customer POV repo, not here.

> Status values: **Pass** · **Pass — design validated** · **Partial** ·
> **Not tested** · **Confirm with Cisco**

## Connectivity & setup

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-1 | Connector reaches the directory | AD/LDAP/Entra | Connector health + Event Log screenshot | | |
| ID-2 | Service account is least-privilege & vaulted | all | Account role export + vault reference | | |
| ID-3 | TLS / cert validated (LDAPS / Graph) | AD/LDAP/Entra | Cert chain / connector TLS config | | |

## Catalog (users / groups / attributes)

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-4 | Users imported | AD/LDAP/Entra | Inventory tab export (JSON/CSV) | | |
| ID-5 | User groups imported | AD/LDAP/Entra | Inventory tab export | | |
| ID-6 | Required attributes imported | AD/LDAP/Entra | Label search showing attributes | | |
| ID-7 | Username mapping correct | AD (`sAMAccountName`) / Entra (`displayName`) | Inventory record screenshot | | |

## Live IP→user mapping

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-8 | On-prem live IP→user (agentless host) | AD agent | Inventory record + login timeline | | |
| ID-9 | Domain-wide coverage (2nd DC) | AD agent | Mapping from second-DC-authenticated host | | |
| ID-10 | Cloud live IP→user | Entra sign-in logs | Inventory record post sign-in | | |

## Labels in scopes / filters

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-11 | Inventory filter on identity label | any | Filter result count + query | | |
| ID-12 | Scope built on identity label | any | Scope membership screenshot | | |
| ID-13 | Flow / dependency view by user context | AD agent / Entra | Flow table filtered by user | | |

## Policy / enforcement (optional)

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-14 | Policy references user-group label (monitor) | any | Policy analysis (predicted allow/deny) | | |
| ID-15 | Windows OS-based user/user-group enforcement | AD + Windows agent | Allow/deny functional test + host log (`csw-logs-check`) | Confirm with Cisco | |
| ID-16 | Enforcement granularity on non-Windows | platform-specific | BU confirmation | Confirm with Cisco | |

## Admin login (if in scope)

| ID | Requirement | Integration | Primary evidence | Status | Evidence link |
|---|---|---|---|---|---|
| ID-17 | AD login to CSW console | External Auth | Successful login as AD user | | |
| ID-18 | MemberOf→role mapping enforced | External Auth | Role/scope shown for mapped vs unmapped user | | |
| ID-19 | Break-glass local admin retained | External Auth | Local admin login confirmed | | |

## Open items / Confirm-with-Cisco log

| Item | Owner | Needed before | Notes |
|---|---|---|---|
| | | | |
