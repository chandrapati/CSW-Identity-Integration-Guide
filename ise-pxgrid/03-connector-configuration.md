---
title: "Cisco Secure Workload — ISE / pxGrid Integration: Connector Configuration"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-12"
---

# Onboard the ISE connector & validate (Phase 5)

With the certificate bundle assembled in
[`02-certificate-setup.md`](./02-certificate-setup.md), configure the ISE
connector in Secure Workload and confirm endpoint/identity context is
flowing.

> Reflects the documented ISE connector workflow as exercised on **Secure
> Workload 3.7**. Confirm field names and placement against your Secure
> Workload User Guide.

---

## 0. Before you start — fill these in

| Setting | Value |
|---|---|
| Target Secure Workload scope | _(decide locally)_ |
| Connector name | e.g. `ise-corp` |
| ISE pxGrid node FQDN / IP | _(from ISE)_ |
| Connector identity FQDN / IP | matches the **CN/SAN** of the client cert |
| Client certificate (PEM) | `ise-connector.pem` (step 13) |
| Private key | `ise-connector.key` (step 4) |
| ISE root CA (PEM) | `rootca.pem` (step 11) |
| Proxy required to reach ISE? | Yes / No |

---

## Step 14 — Upload the certificate bundle to Secure Workload

1. **Manage → Workloads → Connectors** (Connectors page).
2. Select the **ISE** connector and **Configure / enable** it (deploy on
   the appropriate Secure Workload virtual appliance, or via a Secure
   Connector tunnel if ISE is reached that way).
3. Provide the ISE pxGrid connection details and upload the three
   artifacts:
   - **Client certificate** → `ise-connector.pem`
   - **Private key** → `ise-connector.key`
   - **Root CA / trust** → `rootca.pem`
4. Save / create the connector.

This is where the trust you built gets put to use: the connector presents
the client certificate to ISE pxGrid and trusts the ISE node via the root
CA.

> **Approve the client in ISE.** The first time the connector connects,
> the pxGrid client typically appears in ISE pending approval
> (**Administration → pxGrid Services → Clients**, depending on ISE
> release). **Approve** it and confirm the subscription is **active**, or
> no context will flow even with a perfect certificate chain.

---

## Step 15 — Outcome: connector active and ingesting context

When trust is established and the client is approved:

- the Secure Workload **ISE connector** shows **active / connected**, and
- **endpoint and identity context** begins flowing into Secure Workload.

You can now use these attributes as **labels** when building scopes,
inventory filters, and segmentation policy.

---

## Validation & expected results

1. The Secure Workload ISE connector **status** shows **Active /
   connected**.
2. pxGrid **session count increases**; there are **no TLS / certificate
   errors** in the connector logs.
3. **Endpoint attributes** (user, group, device type) appear on the
   Secure Workload **inventory**.
4. The new ISE-sourced **annotations** are selectable when building
   **scopes** and **filters**.
5. **Spot-check** a known endpoint — its identity context in Secure
   Workload matches what ISE shows.

Capture this evidence for a POV in
[`../validation/02-evidence-matrix.md`](../validation/02-evidence-matrix.md).

---

## Next steps — from context to enforced policy

1. Build **scopes / filters** using the new ISE attributes.
2. Use the identity context in **automated policy discovery (ADM)**.
3. Progress target applications from **discovery → enforced
   micro-segmentation** (see
   [`../validation/04-adoption-runbook.md`](../validation/04-adoption-runbook.md)
   and the companion **CSW-Policy-Lifecycle** repo).

For identity-based scope/filter/policy patterns, see
[`../validation/03-user-based-policy-examples.md`](../validation/03-user-based-policy-examples.md).

---

## References

1. Cisco — *Configure and Manage Connectors for Secure Workload* (ISE
   connector), 4.0:
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Cisco — *Cisco ISE pxGrid Services* (client approval / subscriptions;
   consult the guide for your ISE release).
