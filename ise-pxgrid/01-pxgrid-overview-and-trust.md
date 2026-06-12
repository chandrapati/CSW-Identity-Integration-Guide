---
title: "Cisco Secure Workload — ISE / pxGrid Integration: Overview & Trust Model"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-12"
---

# ISE / pxGrid integration — overview & trust model

The Cisco Secure Workload **ISE connector** subscribes to Cisco Identity
Services Engine over **pxGrid** and turns the endpoint and session
context ISE already knows about into **labels** you can use in inventory,
scopes, and segmentation policy.

> Reflects the documented ISE connector / pxGrid certificate workflow as
> exercised on **Secure Workload 3.7**. Cross-check field names and
> placement against your Secure Workload User Guide and ISE pxGrid docs.

---

## Why integrate ISE with Secure Workload

- **Identity-aware segmentation.** Map workloads and sessions to user,
  AD group, device type, and posture — so policy follows *identity*, not
  IP addresses that change.
- **Richer policy labels.** ISE endpoint attributes become annotations in
  Secure Workload, improving discovery, grouping, and automated policy
  generation.
- **Faster, cleaner policy.** Context reduces over-broad rules and
  shortens the path from discovery to least-privilege enforcement.
- **Unified Zero Trust story.** One coherent control plane spanning the
  network (ISE) and the workload (Secure Workload).

---

## How it works (data flow)

```
        Cisco ISE                  Secure Workload ISE connector            Cisco Secure Workload
   ┌──────────────────┐            ┌───────────────────────────┐          ┌──────────────────────┐
   │  pxGrid publisher │  mutual    │  subscribes to pxGrid      │  labels  │ endpoint attributes  │
   │  identity /        │   TLS      │  context (client cert +    │ ───────▶ │ become dimensions    │
   │  endpoint /        │ ─────────▶ │  ISE root CA trust)        │          │ for scopes & policy  │
   │  posture context   │            │                           │          │                      │
   └──────────────────┘            └───────────────────────────┘          └──────────────────────┘
```

1. **ISE** publishes identity, endpoint, and posture context on pxGrid.
2. The Secure Workload **ISE connector** authenticates to the ISE pxGrid
   node with a **client certificate** and subscribes to that context over
   **mutual TLS**.
3. The attributes the connector receives become **labels** in Secure
   Workload, selectable when you build scopes, filters, and policy.

---

## The trust model (read this before `02`)

pxGrid is mutual-TLS. Two trust directions must both succeed:

| Direction | What must be true | Where you set it up |
|---|---|---|
| Connector → ISE | The connector **trusts** the ISE pxGrid node | Upload the **ISE root CA** (PEM) to the connector (step 11) |
| ISE → Connector | ISE **trusts and approves** the connector's client identity | Present a **client cert** signed by your enterprise CA with a matching **CN/SAN** and `clientAuth` EKU (steps 3–13), then **approve** the pxGrid client in ISE |

So the certificate work in [`02-certificate-setup.md`](./02-certificate-setup.md)
produces exactly three artifacts:

1. **pxGrid client certificate** — `clientAuth` EKU, CN + SAN matching the
   connector identity (FQDN **and** IP), signed by your enterprise CA.
2. **Private key** — pairs with (1); keep it secured.
3. **ISE root CA certificate** (PEM) — so the connector trusts ISE.

> **Plan the client identity first.** Decide the connector **FQDN** and
> **IP** up front and put **both** in the CSR's Subject Alternative Name.
> A SAN mismatch is the single most common reason pxGrid rejects a
> client, and fixing it means re-issuing the certificate.

---

## Prerequisites

| Category | Requirement |
|---|---|
| Platforms | Cisco Secure Workload **3.7** (SaaS or on-prem); Cisco ISE with **pxGrid enabled**; an enterprise CA (a **Windows CA** is used in this guide); a Linux host with **OpenSSL** |
| Access | ISE admin (certificates + pxGrid); CA rights to **publish a template** and **sign CSRs**; Secure Workload admin (connector setup) |
| Connectivity | Network reachability from the connector to the ISE **pxGrid** services |
| Certificates | pxGrid client **FQDN and IP** chosen; **SAN** (DNS + IP) planned; ISE pxGrid cert **CA/externally signed**; ISE **root CA exportable** |

---

## The five phases

The configuration is organised into five phases (covered across `02`–`03`):

| Phase | Goal | Steps |
|---|---|---|
| 1 — Prepare the ISE pxGrid certificate | Confirm ISE's pxGrid identity is CA-signed with a valid SAN | 1–2 |
| 2 — Create the client CSR (OpenSSL) | Build the OpenSSL config and generate the CSR + key | 3–4 |
| 3 — Windows CA template & signing | Create a pxGrid template and sign the client CSR | 5–10 |
| 4 — Export & convert the chain | Export the ISE root CA and assemble/verify the bundle | 11–13 |
| 5 — Onboard the connector & validate | Upload the bundle to Secure Workload and confirm context flows | 14–15 |

Continue to [`02-certificate-setup.md`](./02-certificate-setup.md).

---

## References

1. Cisco — *Configure and Manage Connectors for Secure Workload* (ISE
   connector), 4.0:
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Cisco — *Cisco ISE pxGrid* / *Deploying Certificates with Cisco
   pxGrid* (consult the documentation for your ISE release).
