# "AD Agent" — User Identity Reporting from a Domain Controller

This section covers the **live on-prem IP→user** path: installing a
Cisco Secure Workload **agent on a Domain Controller** and enabling
**User Identity Reporting** so CSW learns which user is logged in on
which IP — for **all** domain-joined machines, even those without a CSW
agent.

| Doc | What it does |
|---|---|
| [`01-domain-controller-user-identity.md`](./01-domain-controller-user-identity.md) | Install the agent on a DC, run `CswAgent` under a domain Service Logon Account, enable **Report Users** |
| [`examples/`](./examples/) | Service-account & logon-audit checklist |

## Where this fits

- **Catalog (who exists)** → Identity Connector → AD
  ([`../active-directory/`](../active-directory/README.md)).
- **Live mapping (who is where, now)** → **this** AD-agent path (on-prem)
  or **Entra sign-in logs** (cloud).
- You typically run the **AD catalog connector + the AD agent** together
  for identity-aware policy on-prem.

## How it differs from a normal agent install

A standard CSW agent reports the flows/processes of **its own host**.
The AD-agent path is special: an agent on a **Domain Controller**, with
**Report Users** enabled and running under a **domain Service Logon
Account**, reports **IP→user mappings for the whole domain** by reading
Windows **logon events** — you do **not** need an agent on every
endpoint to get user attribution.

## Dependencies

- The host-agent foundation —
  [`CSW-Agent-Installation-Guide`](https://github.com/chandrapati/CSW-Agent-Installation-Guide)
  (Windows agent install on the DC).
- An **Agent Configuration Profile** that targets the DC with **Report
  Users** enabled.
- Domain **logon auditing** turned on so the events exist to read.

> Introduced in the **3.10.3.x** release train. Confirm availability and
> exact service-account requirements in your release notes.
