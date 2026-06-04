# Prerequisites

Get these right before configuring any connector. Most identity
integration failures trace to one of: an unreachable directory, a
missing service-account role, a TLS trust gap, or an expired secret.

## Common to all paths

| Item | Requirement |
|---|---|
| CSW access | Login with **Site Admin** or scope-owner rights to create connectors |
| Target scope / root scope | Decide which scope the identity data lands in (domain name must be **unique in the selected scope**) |
| Change control | Adding attributes = adding labels that can land in policy — treat as a change |
| Secret storage | A vault (CyberArk / HashiCorp Vault / Azure Key Vault) for service-account passwords, client secrets, and certificates |
| Time sync | NTP on appliances / DCs (Kerberos and log timestamps depend on it) |

## Path 1 & 2 — Identity Connector (AD / OpenLDAP)

| Item | Requirement |
|---|---|
| Connector runtime | A Secure Workload **virtual appliance** able to run the Identity Connector (see *Virtual Appliances for Connectors* in the User Guide for the appliance type/sizing for your release) |
| Network | CSW connector → LDAP/AD server on the LDAP port (**389** plaintext / **636** LDAPS). Prefer **LDAPS**. |
| Reachability fallback | If the directory is not directly reachable: deploy a **Secure Connector** tunnel, or configure an **HTTP proxy** (AD connector supports a proxy option) |
| Service account | A **dedicated, read-only** directory bind account (see below). For AD, a standard domain user with read access to the user/group OUs is sufficient — **no write, no admin**. |
| Base DN | The search base, e.g. `dc=csw,dc=com` |
| User filter | An LDAP filter selecting user entries, e.g. `(&(objectClass=person)(objectClass=user))` |
| TLS | CA certificate for the LDAP server if SSL is enabled (you can disable SSL, but don't in production) |
| OpenLDAP version | OpenLDAP **2.6** for OpenLDAP ingestion |
| Attribute budget | **AD: up to 15** attributes; **OpenLDAP: up to 6** attributes |
| Inventory scale | Recommended limits: **~300,000 users / ~30,000 user groups** displayed |

## Path 3 — Microsoft Entra ID connector

| Item | Requirement |
|---|---|
| App registration | An Entra ID **App Registration** for CSW (see [`entra-id/01-app-registration-graph-permissions.md`](../entra-id/01-app-registration-graph-permissions.md)) |
| Graph permissions (Application) | `Directory.Read.All`, `GroupMember.Read.All`, `User.Read.All`; **`AuditLog.Read.All`** only if enabling sign-in logs — **all require admin consent** |
| Credentials | **TenantID**, **ClientID**, and either a **Client Secret** or a **Client Certificate + Key** (unencrypted, **RSA only**, private key **PKCS1 or PKCS8**) |
| Network | CSW → **Microsoft Graph** over HTTPS (direct or via proxy) |
| Attribute budget | Up to **6** attributes; username mapping → `displayName` |

## Path 4 — User Identity Reporting (AD agent on a Domain Controller)

| Item | Requirement |
|---|---|
| Host | A **Windows Domain Controller** (or a domain-joined Windows host with visibility to logon events, per your release notes) |
| CSW agent | A CSW **Windows agent** installed on that DC (see [`CSW-Agent-Installation-Guide`](https://github.com/chandrapati/CSW-Agent-Installation-Guide)) |
| Service account | The **`CswAgent`** service must run under a **domain Service Logon Account** with rights to read logon events on the domain (Cisco documents a *domain administrator* service account; scope to the minimum your security policy allows and validate) |
| Agent Config Profile | **Report Users** enabled in the **Agent Configuration Profile** that targets the DC |
| Logon auditing | Domain logon **auditing enabled** so the events the agent reads are actually generated |
| Network | Standard agent→cluster connectivity |

## Path 5 (related) — External Authentication (admin login)

| Item | Requirement |
|---|---|
| LDAP reachability | CSW **cluster** → LDAP/AD (TLS strongly recommended) |
| Break-glass | At least one **locally authenticated Site Admin** retained, so a bad LDAP config can't lock everyone out |
| Authorization | `MemberOf` group values to map to CSW roles (if LDAP Authorization is enabled) |

## Service-account checklist (read-only, least privilege)

- Dedicated account per integration; never reuse a human or another
  integration's account.
- **Read-only** to the directory objects in scope; **no** write/admin.
- Password / secret length ≥ 24, vaulted, with a rotation schedule.
- Exempt from interactive-login / MFA *only* where the integration
  cannot perform MFA (document the compensating controls — see
  [`operations/02-security-hardening.md`](../operations/02-security-hardening.md)).
- Where the directory supports it, restrict the account by **source IP**
  to the connector / appliance egress.

## Port quick reference

| From → To | Port | Notes |
|---|---|---|
| CSW connector → AD/LDAP | 389 / **636** | Prefer LDAPS (636) |
| CSW connector → Global Catalog (if used) | 3268 / **3269** | LDAPS GC = 3269 |
| CSW → Microsoft Graph | 443 | Entra ID connector |
| AD agent (DC) → CSW cluster | per Agent Install Guide | Standard agent ports |
| CSW cluster → LDAP (external auth) | 389 / **636** | Admin login path |

> Confirm exact appliance type, sizing, and any release-specific ports
> against the *Virtual Appliances for Connectors* and *Agent
> Installation* sections of the User Guide for your release.
