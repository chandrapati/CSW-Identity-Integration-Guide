# pxGrid certificate — command quick reference

Copy/paste commands for the certificate workflow in
[`../02-certificate-setup.md`](../02-certificate-setup.md). Replace every
placeholder; all names below are examples.

## 1. Generate the CSR + private key (Linux / OpenSSL)

```bash
openssl req -new -newkey rsa:2048 -nodes \
  -keyout ise-connector.key \
  -out    ise-connector.csr \
  -config openssl-pxgrid-csr.cnf

# verify the request: check Subject, SAN, and EKU (clientAuth)
openssl req -in ise-connector.csr -noout -text
```

## 2. Sign the CSR on a Windows enterprise CA

Use a published **PxGrid** certificate template (duplicated from *User*,
with **Client Authentication** in Application Policies):

```bat
certreq -submit -binary -attrib "CertificateTemplate:PxGrid" ^
  ise-connector.csr ise-connector.cer
```

> A warning that the issued validity is shorter than the template
> specifies is the CA's maximum validity capping the cert — informational,
> not an error.

## 3. Export the ISE root CA (ISE UI)

**Administration → System → Certificates → Trusted Certificates →**
select the root CA → **Export** (PEM). Save as `rootca.pem`.

## 4. Convert + verify the chain (Linux / OpenSSL)

```bash
# convert DER (.cer) to PEM
openssl x509 -inform der -in ise-connector.cer -out ise-connector.pem

# verify the client cert chains to the root CA  ->  expect: OK
openssl verify -CAfile rootca.pem ise-connector.pem

# (optional) re-confirm SAN + EKU on the signed cert
openssl x509 -in ise-connector.pem -noout -subject \
  -ext subjectAltName -ext extendedKeyUsage
```

## 5. Bundle to upload to the Secure Workload ISE connector

| File | Role |
|---|---|
| `ise-connector.pem` | pxGrid **client certificate** |
| `ise-connector.key` | **private key** (keep secret) |
| `rootca.pem` | **ISE root CA** (trust) |

After upload, **approve** the pxGrid client in ISE and confirm the
subscription is active — see
[`../03-connector-configuration.md`](../03-connector-configuration.md).
