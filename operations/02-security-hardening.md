---
title: "CSW Identity Integration — Security Hardening"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# Security hardening

Identity integrations hand CSW **read** credentials to your directories
and put a high-value service identity on a Domain Controller. Treat
these as crown-jewel credentials.

## Principles

- **Least privilege, read-only.** Every path here only needs to *read*.
  No write, no admin beyond what's strictly required.
- **Dedicated accounts.** One service identity per integration; never
  reuse a human or another tool's account.
- **No secrets in code or tickets.** Vault everything; reference, don't
  embed.
- **Prefer certificates over secrets** (Entra ID): no plaintext to leak,
  cleaner rotation.
- **Defense in depth.** IP-restrict service accounts to the connector /
  appliance egress where the directory supports it.

## Per-integration hardening

### Identity Connector — AD / OpenLDAP

- Bind account: **read-only** to in-scope OUs; no write/admin.
- **LDAPS (636)**; validate the server certificate; avoid plaintext 389.
- Restrict the bind account by **source IP** to the appliance egress.
- Exclude the bind account from interactive logon.
- Rotate the bind password on schedule; vault it.

### Microsoft Entra ID

- Use **Application** Graph permissions only; nothing beyond
  `Directory.Read.All`, `GroupMember.Read.All`, `User.Read.All`
  (+`AuditLog.Read.All` only if sign-in logs are used).
- Prefer **client certificate** (unencrypted RSA key, PKCS1/PKCS8,
  vaulted) over a client secret.
- If using a secret: short expiry, rotation reminder **before** expiry
  (an expired secret silently breaks the connector).
- Restrict the app's Graph access via Conditional Access / named
  locations where feasible.

### AD agent (User Identity Reporting)

- The `CswAgent` Service Logon Account is **high value** — it reads
  domain logon events from a DC.
- Work with the AD team to scope it to **least privilege** that still
  works (Cisco documents a domain-admin account; validate a tighter
  scope and document the result).
- Grant only **"Log on as a service"** on the DC(s).
- **Monitor** the `CswAgent` service for stop/restart and the account
  for logon failures.
- Vault and rotate the account password; coordinate rotation with the
  service restart.
- Installing software on a DC is a sensitive change — full change
  control, validate DC stability.

### External Authentication (admin login)

- Keep a **break-glass local Site Admin** permanently.
- Use a **dedicated read-only** Admin Credentials bind account for the
  directory query.
- Prefer **LDAPS**; validate the certificate.
- Treat `MemberOf`→role mappings as an **access path** subject to
  periodic access review.

## Secret & certificate lifecycle

| Credential | Store | Rotation | Failure mode if lapsed |
|---|---|---|---|
| AD/LDAP bind password | Vault | Scheduled | Connector auth fails |
| Entra client secret | Vault | Before expiry | Connector 401s silently |
| Entra client certificate | Vault | Before expiry | Connector auth fails |
| DC Service Logon Account | Vault | Scheduled + service restart | User mappings stop |
| Break-glass local admin | Vault | Scheduled | Lockout risk if LDAP also broken |

## Logging & monitoring

- Alert on connector/agent **Event Log** errors.
- Alert on **DC-agent** `Report Users` health and `CswAgent` service
  state.
- Monitor **secret/cert expiry** ahead of time.
- Audit `MemberOf`→role mapping changes (External Auth) as access
  changes.
- Log integration **service-account** auth failures from the directory
  side (possible credential abuse).

## Compliance hooks

Identity-aware segmentation supports several access-control and
least-privilege controls across frameworks. Map the evidence (user/group
labels, identity-scoped policy, access reviews) using
[`CSW-Compliance-Mapping`](https://github.com/chandrapati/CSW-Compliance-Mapping).
