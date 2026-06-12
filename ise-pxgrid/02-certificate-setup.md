---
title: "Cisco Secure Workload — ISE / pxGrid Integration: Certificate Setup"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-12"
---

# pxGrid certificate setup (Phases 1–4)

This is the end-to-end certificate workflow that produces the three trust
artifacts the ISE connector needs (client cert, private key, ISE root
CA). Read [`01-pxgrid-overview-and-trust.md`](./01-pxgrid-overview-and-trust.md)
first for the trust model.

> All hostnames, IPs, and organisation values below are **placeholders**.
> Replace `example.com`, `ise-connector.example.com`, `<ISE_CONNECTOR_IP>`,
> and the `<...>` fields with your own values. A ready-to-edit OpenSSL
> config is in [`examples/openssl-pxgrid-csr.cnf`](./examples/openssl-pxgrid-csr.cnf).

> **Conventions.** A **Windows enterprise CA** signs the client
> certificate; a **Linux host with OpenSSL** generates the CSR/key and
> assembles the final bundle. Adapt the CA steps if you use a different
> CA.

---

## Phase 1 — Prepare the ISE pxGrid certificate

### Step 1 — Confirm the pxGrid certificate is issued by your enterprise CA

In ISE, go to **Administration → System → Certificates → System
Certificates** and confirm the certificate **Used By → pxGrid** is issued
by your **enterprise (external) CA**, not the ISE self-signed CA.

A CA-signed pxGrid identity is what lets the Secure Workload connector
validate the trust chain cleanly. If pxGrid is still using a self-signed
certificate, replace it with a CA-signed certificate before continuing.

### Step 2 — Inspect the pxGrid certificate (SAN + external signing)

Open the pxGrid certificate and verify:

- it is **externally / CA-signed** (not self-signed), and
- the **Subject Alternative Name (SAN)** entries are correct — both the
  **FQDN** and, where used, the **IP**.

SAN mismatches are the most common cause of pxGrid trust failures.
Validate the FQDN and IP here before generating anything.

---

## Phase 2 — Create the pxGrid client CSR (OpenSSL)

### Step 3 — Build the OpenSSL config for the client CSR

On the Linux host, create an OpenSSL config for the pxGrid **client**
certificate request. Replace the placeholders with your environment's
values. Note the key usage — **`clientAuth` is required for pxGrid** —
and that the **SAN must match the client identity**.

```ini
[req]
distinguished_name = req_distinguished_name
req_extensions     = v3_req
x509_extensions    = v3_req
prompt             = no

[req_distinguished_name]
C  = US
ST = <STATE>
L  = <CITY>
O  = <ORGANIZATION>
OU = <ORG_UNIT>
CN = ise-connector.example.com

[v3_req]
subjectKeyIdentifier = hash
basicConstraints     = critical,CA:false
subjectAltName       = @alt_names
keyUsage             = critical,digitalSignature,keyEncipherment
extendedKeyUsage     = serverAuth,clientAuth

[alt_names]
IP.1  = <ISE_CONNECTOR_IP>
DNS.1 = ise-connector.example.com
```

> Keep the **CN** and the **SAN DNS/IP** consistent with the identity the
> connector will present. If you change them later, you must re-issue the
> certificate.

### Step 4 — Generate the CSR and private key

Run OpenSSL against the config to produce the CSR and a 2048-bit (or
stronger) RSA private key:

```bash
openssl req -new -newkey rsa:2048 -nodes \
  -keyout ise-connector.key \
  -out    ise-connector.csr \
  -config openssl-pxgrid-csr.cnf

# inspect the request before sending it for signing
openssl req -in ise-connector.csr -noout -text
```

Confirm the printed **Subject**, **SAN**, and **Extended Key Usage**
(must include **TLS Web Client Authentication**) are correct.

> **Protect `ise-connector.key`.** It pairs with the signed certificate
> the connector uses to authenticate to ISE. Store it securely and never
> commit it to source control.

---

## Phase 3 — Windows CA: template & signing

### Step 5 — Open the Certificate Templates console (MMC)

On the Windows CA, open **MMC** and add the **Certificate Templates**
snap-in (`mmc` → *File → Add/Remove Snap-in → Certificate Templates*).
You will duplicate an existing template to create a dedicated **pxGrid**
template with the correct usages.

### Step 6 — Duplicate the User template for pxGrid

Right-click the built-in **User** template → **Duplicate Template**.
Starting from *User* gives you **Client Authentication**; you will adjust
the remaining properties. Name the duplicate clearly, e.g. **PxGrid**.

### Step 7 — Configure the pxGrid template properties

Configure the new template:

- **Compatibility** — set CA and recipient compatibility appropriate to
  your environment.
- **General** — display name (e.g. `PxGrid`), validity period.
- **Request Handling / Cryptography** — allow the private key to be
  exported only if your process requires it; key size ≥ 2048.
- **Extensions → Application Policies** — ensure **Client Authentication**
  is present (add **Server Authentication** if your process requires it).

### Step 8 — Set subject name and key options

Finish the template by setting **Subject Name** handling (typically
*Supply in the request*, since the subject/SAN come from the OpenSSL CSR)
and the key options so the signed certificate carries the attributes
pxGrid expects. **Publish** the template on the CA
(*Certification Authority → Certificate Templates → New → Certificate
Template to Issue → PxGrid*).

### Step 9 — Transfer the CSR to the Windows CA

Copy `ise-connector.csr` from the Linux host to the Windows CA host (SCP,
file share, etc.) so it can be signed with the pxGrid template.

### Step 10 — Sign the pxGrid client CSR on the Windows CA

Submit and sign the CSR against the CA using the **PxGrid** template. With
`certreq`:

```bat
certreq -submit -binary -attrib "CertificateTemplate:PxGrid" ^
  ise-connector.csr ise-connector.cer
```

This produces the **signed client certificate** (`ise-connector.cer`)
that the connector will present to ISE.

> If the CA warns that the issued validity period is shorter than the
> template specifies, that is the CA's own maximum validity capping the
> certificate — it is informational, not an error.

---

## Phase 4 — Export & convert the chain

### Step 11 — Export the ISE root CA certificate (PEM)

In ISE, go to **Administration → System → Certificates → Trusted
Certificates**, select the **root CA** that signs the pxGrid identity,
and **Export** it in **PEM** format. The connector needs this so it can
trust the ISE pxGrid node.

### Step 12 — Copy the signed cert and root CA to the OpenSSL host

Bring the signed client certificate (`ise-connector.cer`) and the
exported **root CA** (`rootca.pem`) back to the Linux/OpenSSL host so you
can assemble and verify the final bundle.

### Step 13 — Convert the signed cert to PEM and verify the chain

Convert the signed certificate to PEM (Windows CAs typically issue DER),
then verify it chains to the CA:

```bash
# convert DER (.cer) to PEM
openssl x509 -inform der -in ise-connector.cer -out ise-connector.pem

# (if it is already PEM, this is a no-op copy)
# openssl x509 -in ise-connector.cer -out ise-connector.pem

# verify the client cert chains to the ISE/enterprise root CA
openssl verify -CAfile rootca.pem ise-connector.pem
#  => ise-connector.pem: OK
```

A result of **`OK`** confirms the chain. Confirming the chain now avoids
connector errors during onboarding.

You now have the three artifacts for the connector:

| Artifact | File (example) | Purpose |
|---|---|---|
| pxGrid client certificate (PEM) | `ise-connector.pem` | Connector identity presented to ISE |
| Private key | `ise-connector.key` | Pairs with the client certificate |
| ISE root CA (PEM) | `rootca.pem` | Lets the connector trust ISE |

Continue to [`03-connector-configuration.md`](./03-connector-configuration.md).

---

## References

1. Cisco — *Configure and Manage Connectors for Secure Workload* (ISE
   connector), 4.0:
   [On-Prem](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-and-manage-connectors-for-secure-workload.html)
   ·
   [SaaS](https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-saas-v40/m-connectors.html).
2. Cisco — *Deploying Certificates with Cisco pxGrid* (consult the guide
   for your ISE release for template requirements and approval steps).
