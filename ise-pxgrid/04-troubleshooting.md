---
title: "Cisco Secure Workload — ISE / pxGrid Integration: Troubleshooting"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-12"
---

# ISE / pxGrid troubleshooting (quick reference)

Almost every ISE-connector problem traces back to **certificates** or to
the **pxGrid client not being approved**. Use this symptom-first table,
then drop to the detailed checks below.

| Symptom | Likely cause | Fix |
|---|---|---|
| Connector won't authenticate | Client cert not signed correctly / wrong chain | Re-verify the CSR was signed with the **pxGrid template** and the chain validates (step 13, `openssl verify`) |
| TLS / trust errors | **ISE root CA missing** on the connector | Re-export the ISE root CA in **PEM** and include it in the bundle (step 11) |
| pxGrid rejects the client | **SAN mismatch** (FQDN / IP) | Confirm **CN and SAN** match the connector identity; re-issue the cert if needed (steps 2–3) |
| No attributes flowing | pxGrid client **not approved** / subscription inactive | **Approve** the pxGrid client in ISE and confirm the subscription is **active** |
| Auth worked, then stopped | **Certificate expired** | Re-issue the client cert (and check the ISE pxGrid cert hasn't expired) |
| Connector can't reach ISE | Egress / proxy / firewall blocking pxGrid | Allow connectivity to the ISE pxGrid services; set a proxy on the connector if required |

---

## Detailed checks

### 1. Validate the client certificate chain

```bash
# the client cert must report OK against the ISE/enterprise root CA
openssl verify -CAfile rootca.pem ise-connector.pem

# confirm Subject, SAN, and EKU (must include TLS Web Client Authentication)
openssl x509 -in ise-connector.pem -noout -subject -ext subjectAltName -ext extendedKeyUsage
```

- If `verify` does **not** print `OK`, the wrong root CA was exported, or
  an intermediate is missing from the bundle.
- If the EKU does **not** include **clientAuth**, the wrong CA template
  was used — re-issue with the **pxGrid** template (steps 6–10).

### 2. Confirm the SAN matches the connector identity

The CN and the SAN DNS/IP in the client certificate must match the
identity the connector presents. A mismatch is the classic cause of
pxGrid rejecting the client. If they differ, **re-issue** the certificate
with the correct values (steps 3–4 → 10).

### 3. Confirm the ISE side

- The pxGrid client is **approved** in ISE
  (**Administration → pxGrid Services → Clients**, per your ISE release).
- The subscription is **active**.
- The ISE **pxGrid certificate** itself is **CA-signed** and **not
  expired** (steps 1–2).

### 4. Confirm transport

- The connector can reach the ISE **pxGrid** services (DNS resolves,
  ports open, proxy configured if required).
- No TLS errors in the connector event log.

---

## When to escalate

If the chain validates (`OK`), the SAN matches, the client is approved
and active, and transport is open — but context still does not appear —
capture the connector event log and the `openssl` outputs above and
engage your Cisco Secure Workload account team, or
[open a Cisco TAC case](https://www.cisco.com/c/en/us/support/index.html).

See also the cross-integration flowcharts in
[`../operations/01-troubleshooting.md`](../operations/01-troubleshooting.md).
