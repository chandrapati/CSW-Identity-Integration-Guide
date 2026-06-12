# Index — jump table

Fast navigation by question, by integration, and by POV phase.

## By question

| I want to… | Go to |
|---|---|
| Understand the difference between identity *labels* and identity *login* | [`docs/01-concepts-identity-in-csw.md`](./docs/01-concepts-identity-in-csw.md) |
| Decide which integration(s) I need | [`docs/02-decision-matrix.md`](./docs/02-decision-matrix.md) |
| Know what appliances / ports / accounts to prepare | [`docs/03-prerequisites.md`](./docs/03-prerequisites.md) |
| Import AD users + groups as labels | [`active-directory/01-identity-connector-ad.md`](./active-directory/01-identity-connector-ad.md) |
| Import OpenLDAP users + groups | [`active-directory/02-openldap-connector.md`](./active-directory/02-openldap-connector.md) |
| Let admins log into CSW with AD creds (RBAC) | [`active-directory/03-external-auth-ldap-rbac.md`](./active-directory/03-external-auth-ldap-rbac.md) |
| Register a Graph app for Entra ID | [`entra-id/01-app-registration-graph-permissions.md`](./entra-id/01-app-registration-graph-permissions.md) |
| Configure the Entra ID connector | [`entra-id/02-entra-id-connector.md`](./entra-id/02-entra-id-connector.md) |
| Get near-real-time IP→user from Entra sign-ins | [`entra-id/03-sign-in-logs-user-mapping.md`](./entra-id/03-sign-in-logs-user-mapping.md) |
| Get live IP→user for the whole on-prem domain | [`ad-agent/01-domain-controller-user-identity.md`](./ad-agent/01-domain-controller-user-identity.md) |
| Bring live ISE endpoint/session identity into CSW (pxGrid) | [`ise-pxgrid/01-pxgrid-overview-and-trust.md`](./ise-pxgrid/01-pxgrid-overview-and-trust.md) |
| Build & sign the pxGrid client certificate | [`ise-pxgrid/02-certificate-setup.md`](./ise-pxgrid/02-certificate-setup.md) |
| Configure the ISE connector in CSW | [`ise-pxgrid/03-connector-configuration.md`](./ise-pxgrid/03-connector-configuration.md) |
| Fix a pxGrid trust / connection problem | [`ise-pxgrid/04-troubleshooting.md`](./ise-pxgrid/04-troubleshooting.md) |
| Run a POV | [`validation/01-pov-test-plan.md`](./validation/01-pov-test-plan.md) |
| Score POV requirements | [`validation/02-evidence-matrix.md`](./validation/02-evidence-matrix.md) |
| Write scopes / filters / policy on identity | [`validation/03-user-based-policy-examples.md`](./validation/03-user-based-policy-examples.md) |
| Roll identity out to production | [`validation/04-adoption-runbook.md`](./validation/04-adoption-runbook.md) |
| Fix labels that aren't appearing | [`operations/01-troubleshooting.md`](./operations/01-troubleshooting.md) |
| Harden the integration service accounts | [`operations/02-security-hardening.md`](./operations/02-security-hardening.md) |

## By integration

| Integration | Primary doc | Type | Read-only? |
|---|---|---|---|
| Active Directory (Identity Connector) | [`active-directory/01-identity-connector-ad.md`](./active-directory/01-identity-connector-ad.md) | Connector | Yes |
| OpenLDAP (Identity Connector) | [`active-directory/02-openldap-connector.md`](./active-directory/02-openldap-connector.md) | Connector | Yes |
| External Authentication (LDAP/AD) | [`active-directory/03-external-auth-ldap-rbac.md`](./active-directory/03-external-auth-ldap-rbac.md) | Cluster auth | Yes |
| Microsoft Entra ID | [`entra-id/02-entra-id-connector.md`](./entra-id/02-entra-id-connector.md) | Connector (Graph) | Yes |
| User Identity Reporting (AD agent) | [`ad-agent/01-domain-controller-user-identity.md`](./ad-agent/01-domain-controller-user-identity.md) | Host agent on DC | Yes (reads logon events) |
| Cisco ISE (pxGrid) | [`ise-pxgrid/01-pxgrid-overview-and-trust.md`](./ise-pxgrid/01-pxgrid-overview-and-trust.md) | Connector (pxGrid / mTLS) | Yes (subscribes to context) |

## By POV phase

| Phase | Activity | Doc |
|---|---|---|
| 1 — Setup | Appliance / app reg / service accounts | [`docs/03-prerequisites.md`](./docs/03-prerequisites.md) |
| 2 — Connect | Stand up the chosen connector(s) | per-integration runbooks |
| 3 — Inventory | Confirm users / groups / attributes imported | [`validation/01-pov-test-plan.md`](./validation/01-pov-test-plan.md) |
| 4 — Label & scope | Use identity labels in scopes & filters | [`validation/03-user-based-policy-examples.md`](./validation/03-user-based-policy-examples.md) |
| 5 — Policy (optional) | Identity in policy where supported | [`validation/03-user-based-policy-examples.md`](./validation/03-user-based-policy-examples.md) |
| 6 — Hand-off | Evidence + adoption plan | [`validation/02-evidence-matrix.md`](./validation/02-evidence-matrix.md), [`validation/04-adoption-runbook.md`](./validation/04-adoption-runbook.md) |
