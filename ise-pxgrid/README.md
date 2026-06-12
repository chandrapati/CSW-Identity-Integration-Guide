# "ISE / pxGrid" — Cisco ISE Connector for Secure Workload

This section covers integrating **Cisco Identity Services Engine (ISE)**
with Cisco Secure Workload via the **ISE connector**, which subscribes to
ISE over **pxGrid**. It brings **endpoint and session identity context**
(logged-in user, endpoint/device attributes, and where deployed, security
group context) into Secure Workload so it can be used as **labels** for
inventory, scopes, and segmentation policy.

Unlike the directory connectors (which read the *catalog* of users and
groups), the ISE connector learns **who and what is actually on the
network right now** — the live IP → endpoint → user context that ISE
already maintains.

| Doc | What it does |
|---|---|
| [`01-pxgrid-overview-and-trust.md`](./01-pxgrid-overview-and-trust.md) | Concepts, data flow, and the certificate trust model that the rest of the section builds |
| [`02-certificate-setup.md`](./02-certificate-setup.md) | End-to-end certificate workflow — verify the ISE pxGrid cert, build and sign a pxGrid **client** certificate, export the root CA, and assemble the bundle |
| [`03-connector-configuration.md`](./03-connector-configuration.md) | Create and configure the ISE connector in Secure Workload, upload the certificate bundle, and validate the feed |
| [`04-troubleshooting.md`](./04-troubleshooting.md) | Symptom-first quick reference for the issues you will actually hit |
| [`examples/`](./examples/) | A ready-to-edit OpenSSL config for the pxGrid client CSR and the Windows CA signing commands |

## When to use this vs. the other paths

- **You run Cisco ISE** and want live **endpoint/session identity**
  (device type, user, posture context) in Secure Workload → this section.
- **You want the directory catalog** of users/groups for labelling →
  [`../active-directory/`](../active-directory/README.md) or
  [`../entra-id/`](../entra-id/README.md).
- **On-prem live IP→user without ISE** → the
  [`../ad-agent/`](../ad-agent/README.md) path (agent on a Domain
  Controller).
- **Many estates run more than one** — e.g. the AD connector for the
  group catalog *and* the ISE connector for live endpoint context.

## Read-only

The ISE connector **subscribes** to context published by ISE over
pxGrid. It does not push policy or configuration into ISE. Trust is
mutual-TLS: the connector presents a **client certificate** signed by
your enterprise CA, and trusts the ISE node via the **ISE root CA**.

## Key facts

- **Transport:** pxGrid over **mutual TLS** between the Secure Workload
  ISE connector and the ISE pxGrid node(s).
- **Trust material (what you build in `02`):**
  1. a **pxGrid client certificate** (CN + SAN matching the connector
     identity, `clientAuth` EKU) signed by your enterprise CA;
  2. the matching **private key**;
  3. the **ISE root CA** certificate (PEM) so the connector trusts ISE.
- **The #1 cause of failure is certificates** — wrong template, missing
  root CA, or a **SAN mismatch** (FQDN/IP). Plan the client identity
  *before* you generate the CSR.
- **ISE side:** the pxGrid client must be **approved** in ISE and the
  subscription **active**, or no context flows even with perfect certs.

> **Status / accuracy.** This section reflects the documented Cisco ISE
> connector / pxGrid certificate workflow as exercised on **Secure
> Workload 3.7**. Field names and connector placement change between
> releases — **always cross-check the Cisco Secure Workload User Guide
> and your ISE version's pxGrid documentation** before relying on this in
> a customer engagement. When this guide and the official docs disagree,
> the official docs win.
