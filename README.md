# Cisco Secure Workload — Identity Integration Guide

A practitioner-oriented reference for bringing **user and directory
identity** into Cisco Secure Workload (CSW, formerly *Tetration*) so
that segmentation policy, inventory, and forensic events can be
expressed and investigated in terms of **who** — not just which IP.
Written for security engineers, identity / Active Directory owners,
and POV teams who need to get from *"we have CSW seeing flows"* to
*"we can scope, label, and (where supported) enforce on user and
user-group identity"* without surprises.

This repo covers the three identity paths customers ask about by name:

| You said… | CSW mechanism this repo documents | Folder |
|---|---|---|
| **"CSW AD"** | **Identity Connector → Active Directory** (and OpenLDAP) — imports users / user groups and their attributes | [`active-directory/`](./active-directory/README.md) |
| **"Entra AD"** | **Microsoft Entra ID Connector** — Graph API app registration; user / group inventory + sign-in (event) logs | [`entra-id/`](./entra-id/README.md) |
| **"AD Agent"** | **User Identity Reporting from a Domain Controller** — CSW agent on a DC reports IP→user mappings for the whole domain | [`ad-agent/`](./ad-agent/README.md) |

> **Status.** Draft v1 (June 2026). Patterns and field tables are
> documentation-grade and reflect the **CSW 4.0 / 3.10** User Guides.
> The authoritative source for any specific release is the *Cisco
> Secure Workload User Guide* and your release notes — always
> cross-check version-specific behaviour there before relying on this
> repository in a customer engagement. **When this guide and the User
> Guide disagree, the User Guide wins.**

> **Official Cisco documentation — start here:**
> [Configure and Manage Connectors — On-Prem 4.0](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
> · [SaaS 4.0](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
> A consolidated cross-reference is in
> [`docs/00-official-references.md`](./docs/00-official-references.md)
> — read it before any new configuration attempt.

---

## For executives — at a glance

> **CISO / identity-owner read.** Identity integration is what turns
> CSW from an *IP-based* segmentation tool into one that speaks your
> organisation's language — users, groups, departments, and
> directories. It is **read-only** against your identity stores and
> changes nothing in AD / Entra ID.

- **What it does.** CSW pulls **users, user groups, and selected
  attributes** from Active Directory, OpenLDAP, or Microsoft Entra ID,
  and (via the AD-agent path) learns **which user is logged in on which
  IP**. Those become **labels** you can use in scopes, inventory
  filters, and policy.
- **Does it touch my directory?** No. Every path in this repo is a
  **read-only pull** from the identity store. CSW never writes users,
  groups, or attributes back to AD / Entra ID.
- **What it is *not*.** This is **not** the same as logging *admins*
  into the CSW console with AD credentials — that is *External
  Authentication* and is documented separately in
  [`active-directory/03-external-auth-ldap-rbac.md`](./active-directory/03-external-auth-ldap-rbac.md).
- **Why it matters for a POV.** "Block lateral movement *from
  contractors* to the PCI scope" is a far stronger story than "block
  10.20.0.0/16 to 10.30.0.0/16". Identity labels are what make that
  sentence expressible.
- **Where enforcement on user identity is real today.** Windows
  agents support **user / user-group-based policy** on the host;
  confirm scope of support for your release with your Cisco account
  team (see [`docs/02-decision-matrix.md`](./docs/02-decision-matrix.md)).

---

## What's in this repo

```
CSW-Identity-Integration-Guide/
├── README.md                  ← you are here (overview + decision matrix)
├── INDEX.md                   ← jump table by question / by integration
├── docs/                      ← background concepts (read first)
│   ├── 00-official-references.md   ← Cisco doc cross-reference (read first!)
│   ├── 01-concepts-identity-in-csw.md ← labels vs. auth; the 3 paths; data flow
│   ├── 02-decision-matrix.md       ← which integration for which need
│   └── 03-prerequisites.md         ← appliances, ports, accounts, certs
├── active-directory/          ← "CSW AD" — Identity Connector (AD + OpenLDAP)
│   ├── README.md
│   ├── 01-identity-connector-ad.md     ← AD user/group import + labels
│   ├── 02-openldap-connector.md        ← OpenLDAP variant
│   ├── 03-external-auth-ldap-rbac.md   ← admin login + MemberOf→role mapping
│   └── examples/                       ← LDAP filters, attribute maps
├── entra-id/                  ← "Entra AD" — Microsoft Entra ID Connector
│   ├── README.md
│   ├── 01-app-registration-graph-permissions.md ← app reg + Graph permissions
│   ├── 02-entra-id-connector.md        ← connector config (tenant/client/secret)
│   ├── 03-sign-in-logs-user-mapping.md ← AuditLog sign-in → IP→user mapping
│   └── examples/                       ← az CLI app-registration helper
├── ad-agent/                  ← "AD Agent" — User Identity from Domain Controller
│   ├── README.md
│   ├── 01-domain-controller-user-identity.md ← agent on DC + Report Users
│   └── examples/                       ← service-account checklist
├── validation/                ← POV + adoption
│   ├── README.md
│   ├── 01-pov-test-plan.md             ← phased test plan + pass criteria
│   ├── 02-evidence-matrix.md           ← requirement → evidence → scoring
│   ├── 03-user-based-policy-examples.md ← scopes/filters/policies on identity
│   └── 04-adoption-runbook.md          ← crawl→walk→run for production
├── operations/                ← day-2
│   ├── README.md
│   ├── 01-troubleshooting.md           ← symptom-first flowcharts
│   └── 02-security-hardening.md        ← service-account + secret hygiene
├── docs/_build/
│   └── build_docx.sh          ← pandoc → .docx for customer hand-off
├── .gitignore
└── LICENSE
```

---

## How to use this guide

1. **Read [`docs/00-official-references.md`](./docs/00-official-references.md) first.**
   It pins the canonical Cisco pages for each integration and the
   release where each feature appears.
2. **Read [`docs/01-concepts-identity-in-csw.md`](./docs/01-concepts-identity-in-csw.md).**
   The single most common confusion in this space is *identity for
   labels* vs *identity for admin login*. This doc draws the line and
   shows the data flow for each of the three paths.
3. **Pick your path from [`docs/02-decision-matrix.md`](./docs/02-decision-matrix.md).**
   Most customers run **more than one** — e.g. Entra ID for cloud
   identity inventory *and* the AD-agent path for live IP→user mapping
   on-prem.
4. **Follow the per-integration runbook** under
   [`active-directory/`](./active-directory/README.md),
   [`entra-id/`](./entra-id/README.md), or
   [`ad-agent/`](./ad-agent/README.md). Each is self-contained:
   prerequisites, config steps with field tables, validation, common
   errors.
5. **For a POV, drive from [`validation/01-pov-test-plan.md`](./validation/01-pov-test-plan.md)**
   and capture results in
   [`validation/02-evidence-matrix.md`](./validation/02-evidence-matrix.md).
6. **For production, follow [`validation/04-adoption-runbook.md`](./validation/04-adoption-runbook.md)**
   — crawl (inventory only) → walk (labels in scopes) → run
   (identity in policy).

---

## The three identity paths at a glance

| Path | What CSW learns | Where it runs | Best for |
|---|---|---|---|
| **Identity Connector → Active Directory** | Users, user groups, up to **15** AD attributes; `sAMAccountName` username mapping | Connector on a Secure Workload **virtual appliance** (or via Secure Connector tunnel) | Importing the AD user/group catalog for labelling and scope design |
| **Identity Connector → OpenLDAP** | Users, user groups, up to **6** attributes | Same appliance / Secure Connector | Non-AD LDAP directories (OpenLDAP 2.6) |
| **Microsoft Entra ID Connector** | Users, user groups, up to **6** attributes; `displayName` mapping; **sign-in logs** for near-real-time IP→user | CSW connector calling **Microsoft Graph** (app registration) | Cloud-first / Entra-ID-primary estates; live cloud sign-in mapping |
| **User Identity Reporting (AD Agent)** | **Live IP→logged-in-user** for *all* domain-joined machines | CSW **agent installed on a Domain Controller**, `CswAgent` under a domain Service Logon Account | On-prem real-time "who is on this host right now" without an agent on every endpoint |
| *(related)* **External Authentication (LDAP/AD)** | *Admin* login + `MemberOf`→role | CSW cluster config (not a connector) | Logging operators into the CSW console with AD creds |

Detailed comparison and decision tree in
[`docs/02-decision-matrix.md`](./docs/02-decision-matrix.md).

---

## Companion repositories

This repo is the **identity** chapter of the CSW practitioner toolkit:

- [`chandrapati/CSW-Agent-Installation-Guide`](https://github.com/chandrapati/CSW-Agent-Installation-Guide)
  — deploying the host agent (the AD-agent path depends on installing
  an agent on a Domain Controller).
- [`chandrapati/CSW-Policy-Lifecycle`](https://github.com/chandrapati/CSW-Policy-Lifecycle)
  — ADM → Monitor → Simulate → Enforce; where identity labels become
  policy.
- [`chandrapati/CSW-Compliance-Mapping`](https://github.com/chandrapati/CSW-Compliance-Mapping)
  — framework mappings (identity-aware segmentation supports several
  access-control controls).
- [`chandrapati/csw-splunk-integration`](https://github.com/chandrapati/csw-splunk-integration)
  — exporting user-attributed flow / forensic events to the SOC.

> **Suggested path for a new customer:**
> CSW-Agent-Installation-Guide → **CSW-Identity-Integration-Guide** →
> CSW-Policy-Lifecycle → csw-splunk-integration → CSW-Compliance-Mapping.

---

## Disclaimer

The patterns, command examples, field tables, and operational guidance
in this repository are provided for **informational and reference
purposes only**. They are not a substitute for the official Cisco
Secure Workload product documentation, your organisation's
change-management process, or a qualified consulting engagement.

- Field names, limits (attribute counts, inventory caps), and connector
  placement follow what Cisco documents for **CSW 4.0 / 3.10**.
  Limits and behaviour change between releases — confirm against the
  User Guide and release notes shipped with your specific cluster.
- The **AD-agent / User Identity Reporting** capability and the
  **Entra ID sign-in log** capability were introduced/updated in the
  3.10.x release train; confirm availability in your release notes.
- Identity stores are **never written to** by any path in this repo —
  all integrations are read-only pulls. Service accounts should be
  least-privilege and vaulted; see
  [`operations/02-security-hardening.md`](./operations/02-security-hardening.md).

### Questions, sizing, licensing, or release specifics?

For anything that depends on your specific deployment — release-version
behaviour, supported enforcement granularity on user identity, sizing,
or licensing — **reach out to your Cisco Secure Workload account team**
(your assigned Cisco SE or partner SE). For incidents on a deployed
cluster, [open a Cisco TAC case](https://www.cisco.com/c/en/us/support/index.html).

This document should receive subject-matter-expert review before being
used to gate any production change.
