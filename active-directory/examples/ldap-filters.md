# LDAP / AD user-filter cookbook

Reusable `User Filter` values for the Identity Connector (AD and
OpenLDAP). Test filters with `ldapsearch` or ADSI Edit before pasting
into the connector.

## Active Directory

| Goal | Filter |
|---|---|
| All users | `(&(objectClass=person)(objectClass=user))` |
| Active users only (exclude disabled) | `(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))` |
| Members of a group (by DN) | `(&(objectClass=user)(memberOf=CN=PCI-Admins,OU=Groups,DC=csw,DC=com))` |
| Nested group membership (LDAP_MATCHING_RULE_IN_CHAIN) | `(&(objectClass=user)(memberOf:1.2.840.113556.1.4.1941:=CN=PCI-Admins,OU=Groups,DC=csw,DC=com))` |
| Department | `(&(objectClass=user)(department=Finance))` |
| CN contains keyword | `(&(objectClass=user)(cn=*Marketing*))` |
| Exclude service accounts by naming convention | `(&(objectClass=user)(!(sAMAccountName=svc_*)))` |

## OpenLDAP

| Goal | Filter |
|---|---|
| All people | `(objectClass=person)` |
| People with a uid | `(&(objectClass=person)(uid=*))` |
| Members of a posixGroup (resolve separately) | `(&(objectClass=person)(gidNumber=5001))` |

## Test commands

```bash
# AD over LDAPS, from the connector/appliance network
ldapsearch -H ldaps://dc01.csw.com:636 \
  -D "svc_csw_identity@csw.com" -W \
  -b "dc=csw,dc=com" \
  "(&(objectClass=person)(objectClass=user))" sAMAccountName department memberOf

# OpenLDAP
ldapsearch -H ldaps://ldap01.csw.com:636 \
  -D "cn=svc_csw_identity,dc=csw,dc=com" -W \
  -b "dc=csw,dc=com" \
  "(objectClass=person)" uid cn
```

> Use the **`-W`** prompt or a vaulted secret reference — never put the
> bind password on the command line or in shell history.
