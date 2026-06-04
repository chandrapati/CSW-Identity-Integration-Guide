---
title: "Cisco Secure Workload — External Authentication (LDAP/AD) + RBAC"
subtitle: "CSW Identity Integration Guide"
author: "Cisco Secure Workload"
date: "2026-06-04"
---

# External Authentication (LDAP/AD) and LDAP Authorization

This is the **admin-login** path: letting operators sign into the Cisco
Secure Workload **console** with their AD/LDAP credentials, and mapping
their AD **`MemberOf`** groups to CSW **roles**.

> **This is not a labelling connector.** It does not put users or groups
> onto workload inventory. If you want identity *labels*, use the
> Identity Connector ([`01-identity-connector-ad.md`](./01-identity-connector-ad.md)).
> This page is included because customers ask for both AD integrations
> together.

> Verified against the **CSW 4.0 On-Prem** *Configure External
> Authentication* page.

---

## TL;DR

- **What it is.** Hand off CSW **console authentication** to **LDAP**
  (AD) or **SSO**. Optionally, **LDAP Authorization** maps AD groups to
  CSW roles automatically on login.
- **Critical safety rule.** Keep **at least one locally authenticated
  Site Admin** with **Use Local Authentication** enabled, so a broken
  LDAP config cannot lock everyone out.
- **Authorization.** Enable the **LDAP Authorization** checkbox in the
  **Admin Credentials** section, then map `MemberOf` group values to CSW
  roles. Without it, AD users must be pre-assigned CSW roles before they
  log in.

---

## 1. How it works

- When **External Authentication → LDAP** is enabled, users sign in with
  their **LDAP email and password**; all users are logged out and
  subsequent logins use LDAP.
- With **LDAP Authorization** enabled, the Site Admin maps **LDAP
  `MemberOf` group** values → **CSW roles**. On each login the user is
  authorized based on those mappings.
- Without LDAP Authorization, AD users must be **preconfigured** with one
  or more CSW roles prior to their first login.

---

## 2. Safe enablement sequence (do not skip)

1. **Before enabling**, confirm at least one **local Site Admin** exists
   with **Use Local Authentication** checked. This is your break-glass.
2. Configure the **LDAP connection** (server, Base DN, bind, TLS) and
   the **Admin Credentials** used to query the directory.
3. **Test** with the local Site Admin still active. Verify a known AD
   user can authenticate.
4. Enable **LDAP Authorization** and create **`MemberOf` → role**
   mappings (see §3).
5. Only after verifying logins and role assignment, transition
   individual users off **Use Local Authentication** (uncheck it in the
   user edit flow). **Keep one local Site Admin** as permanent
   break-glass.

> Enabling LDAP **logs everyone out**; subsequent logins use LDAP.
> Schedule a change window and have the break-glass account credentials
> in hand.

---

## 3. MemberOf → role mapping

1. In the External Authentication LDAP config, **Admin Credentials**
   section, enable the **LDAP Authorization** checkbox.
2. Use **Create Mapping** to map an LDAP `MemberOf` group value to a CSW
   role. The role dropdown is prepopulated based on the **scope**
   selected in the scope selector.
3. Save. On subsequent logins, users are authorized by these mappings.

Example mapping plan:

| AD group (`MemberOf`) | CSW role | Scope |
|---|---|---|
| `CN=CSW-SiteAdmins,OU=Groups,DC=csw,DC=com` | Site Admin | Root |
| `CN=CSW-PCI-Enforcers,OU=Groups,DC=csw,DC=com` | Enforce | `Root:PCI` |
| `CN=CSW-ReadOnly,OU=Groups,DC=csw,DC=com` | Read-only | Root |

---

## 4. Validation

- Log in as an AD user in a mapped group → confirm the expected **role**
  and **scope access**.
- Log in as an AD user **not** in any mapped group → confirm **least
  privilege** (no unintended access).
- Confirm the **local Site Admin** still works (break-glass).

---

## 5. Hardening notes

- Prefer **LDAPS**; validate the server certificate.
- Use a **dedicated read-only** Admin Credentials bind account for the
  directory query.
- Audit `MemberOf`→role mappings as part of access reviews — an AD group
  membership change now grants/revokes CSW access.
- Keep the break-glass local Site Admin password vaulted and rotated.

---

## References

1. Cisco — *Configure External Authentication* (On-Prem 4.0):
   <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/4_0/cisco-secure-workload-user-guide-on-prem-v40/configure-external-athentication.html>
2. Cisco — *Setup System Configurations in Secure Workload → Configure
   LDAP / LDAP Authorization* (3.9 reference):
   <https://www.cisco.com/c/en/us/td/docs/security/workload_security/secure_workload/user-guide/3_9/cisco-secure-workload-user-guide-on-prem-v39/set-up-system-configurations-in-secure-workload.html>
