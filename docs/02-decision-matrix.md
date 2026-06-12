# Decision matrix — which integration do you need?

Most customers run **more than one** of these. Use the matrix to pick a
starting point and the decision tree to combine paths.

## Need → integration

| Your need | Recommended path | Folder |
|---|---|---|
| "Label workloads with the department / group of the user who owns them" | Identity Connector → **AD** (catalog), then apply attributes as labels | [`active-directory/`](../active-directory/README.md) |
| "We're on OpenLDAP, not AD" | Identity Connector → **OpenLDAP** | [`active-directory/02-openldap-connector.md`](../active-directory/02-openldap-connector.md) |
| "Entra ID is our source of truth for identity" | **Microsoft Entra ID** connector | [`entra-id/`](../entra-id/README.md) |
| "Show me, live, which user is on which on-prem host" | **User Identity Reporting** (AD agent on a DC) | [`ad-agent/`](../ad-agent/README.md) |
| "Show me, live, which user signed in from which IP in the cloud" | Entra ID connector with **sign-in logs** enabled | [`entra-id/03-sign-in-logs-user-mapping.md`](../entra-id/03-sign-in-logs-user-mapping.md) |
| "We run Cisco ISE — bring its live endpoint/session identity into CSW" | **ISE connector** over **pxGrid** (mutual TLS) | [`ise-pxgrid/`](../ise-pxgrid/README.md) |
| "Let our operators log into the CSW console with AD creds" | **External Authentication** (LDAP) + LDAP Authorization | [`active-directory/03-external-auth-ldap-rbac.md`](../active-directory/03-external-auth-ldap-rbac.md) |
| "Enforce a rule that blocks *contractors* from the PCI scope" | AD/Entra **catalog** for the group label + **AD agent / Entra sign-ins** for live mapping + **Windows OS-based policy** | combine all three; see caveat below |

## Catalog vs. live mapping — the key distinction

| | Catalog (who exists) | Live mapping (who is where, now) |
|---|---|---|
| AD | Identity Connector → AD | **AD agent** (User Identity Reporting) |
| OpenLDAP | Identity Connector → OpenLDAP | *(no native live mapping)* |
| Entra ID | Entra ID connector | Entra ID **sign-in logs** |

You almost always want **both** columns for identity-aware policy: the
catalog provides the group/attribute vocabulary; the live mapping binds
that vocabulary to current IPs.

## Decision tree

```text
Is the directory Microsoft Entra ID (cloud)?
├── Yes → Entra ID connector
│         └── Need live IP→user for cloud sign-ins? → enable sign-in logs (AuditLog.Read.All)
└── No (on-prem AD or OpenLDAP)
    ├── Need the user/group catalog for labels & scopes?
    │     ├── AD       → Identity Connector → Active Directory
    │     └── OpenLDAP → Identity Connector → OpenLDAP
    ├── Need live "who is logged in on this host" on-prem?
    │     └── User Identity Reporting → install CSW agent on a Domain Controller
    └── Need operators to log into the CSW UI with AD creds?
          └── External Authentication (LDAP) + LDAP Authorization (MemberOf→role)
```

## Connector placement & reachability

| Path | Where the integration runs | If the source is not directly reachable |
|---|---|---|
| Identity Connector → AD / OpenLDAP | Connector reachable from CSW (virtual appliance) | Enable **Secure Connector** tunnel; or allow an **HTTP proxy** |
| Entra ID connector | CSW → **Microsoft Graph** over the internet | Allow outbound HTTPS / proxy to Graph endpoints |
| AD agent | CSW **agent on a Domain Controller** | Standard agent→cluster connectivity (see Agent Installation Guide) |
| ISE connector (pxGrid) | CSW **ISE connector** → ISE **pxGrid** node (mutual TLS) | Enable **Secure Connector** tunnel / allow proxy; ensure pxGrid reachability |
| External Authentication | CSW **cluster** → LDAP/AD | Cluster must reach the LDAP server (TLS recommended) |

See [`docs/03-prerequisites.md`](./03-prerequisites.md) for sizing,
ports, accounts, and certificates.

## Enforcement-on-identity caveat (read before you promise it)

- **Visibility & labelling on identity** — broadly supported across all
  paths once the connector / agent is healthy.
- **Enforcement on user / user-group** — strongest on **Windows agents**
  via OS-based filtering attributes (*Policies Based on User Group or
  User Name*). Linux/other-platform user-based enforcement granularity
  is **release- and platform-specific**.
- **Action for POV:** validate the exact enforcement granularity for the
  customer's release with the Cisco account/BU team and mark it
  **"Confirm with Cisco"** in
  [`validation/02-evidence-matrix.md`](../validation/02-evidence-matrix.md)
  until demonstrated. Do not over-commit enforcement scope in a
  requirements response.
