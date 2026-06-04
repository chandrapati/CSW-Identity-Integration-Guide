# "CSW AD" — Identity Connector for Active Directory & OpenLDAP

This section covers importing your **on-prem directory catalog** —
users, user groups, and selected attributes — into Cisco Secure
Workload using the **Identity Connector**, plus the related
**External Authentication** path for logging operators into the CSW
console with AD credentials.

| Doc | What it does |
|---|---|
| [`01-identity-connector-ad.md`](./01-identity-connector-ad.md) | Configure the Identity Connector against **Active Directory** — user/group import, up to 15 attributes, `sAMAccountName` mapping |
| [`02-openldap-connector.md`](./02-openldap-connector.md) | Same, against **OpenLDAP** (2.6) — up to 6 attributes |
| [`03-external-auth-ldap-rbac.md`](./03-external-auth-ldap-rbac.md) | **Admin login** via LDAP + LDAP Authorization (`MemberOf`→CSW role). *Not* a labelling connector |
| [`examples/`](./examples/) | Reusable LDAP filters and attribute maps |

## Which one do I want?

- **Label workloads / design scopes by user attribute or group** →
  `01` (AD) or `02` (OpenLDAP). This is the "CSW AD" connector most
  people mean.
- **Live "who is logged in on this host right now" on-prem** → that's
  the **AD agent**, not this connector. See [`../ad-agent/`](../ad-agent/README.md).
- **Operators logging into the CSW UI with AD creds** → `03`.

## Read-only

The Identity Connector performs a **read-only** bind to your directory
and pulls the user/group catalog on a schedule. It never writes back to
AD / LDAP. Use a **dedicated, least-privilege, read-only** bind account
— see [`../docs/03-prerequisites.md`](../docs/03-prerequisites.md) and
[`../operations/02-security-hardening.md`](../operations/02-security-hardening.md).

## Prerequisites recap

- A Secure Workload **virtual appliance** to host the connector (or a
  **Secure Connector** tunnel / HTTP proxy if the directory isn't
  directly reachable).
- A read-only directory bind account, Base DN, and a user filter.
- LDAPS CA certificate (recommended over plaintext 389).

Full list: [`../docs/03-prerequisites.md`](../docs/03-prerequisites.md).
