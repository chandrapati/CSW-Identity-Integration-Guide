# AD-agent service account & logon-audit checklist

For the **User Identity Reporting from a Domain Controller** path. Work
this with the AD / domain-admin team; the `CswAgent` service identity is
a high-value credential.

## Service Logon Account

- [ ] **Dedicated** domain account for the `CswAgent` service (not a
      personal admin, not reused from another tool). Suggested name:
      `svc_csw_agent_dc`.
- [ ] Granted the **"Log on as a service"** right on the DC(s)
      (via GPO or local security policy).
- [ ] Has the rights required to **read domain logon events**. Cisco
      documents a **domain-administrator** Service Logon Account; with
      your AD team, determine the **least privilege** that still works,
      document it, and validate user mappings populate. Mark **"Confirm
      with Cisco"** until proven.
- [ ] Password length ≥ 24, **vaulted**, with a rotation schedule.
- [ ] Excluded from interactive/console logon where possible (it's a
      service identity).
- [ ] Monitored: alert on `CswAgent` service stop/restart and on
      logon failures for this account.

## Domain logon auditing

- [ ] **Audit Logon Events** and/or **Audit Account Logon Events**
      enabled via GPO on the domain controllers.
- [ ] Security event log sized so high-volume logon events aren't
      rolled before the agent reads them.

## Agent Configuration Profile

- [ ] A profile that **targets the DC(s)** has **Report Users** enabled.
- [ ] Profile applied and confirmed on the DC agent.

## Redundancy & rollout

- [ ] Agent installed on **≥2 DCs** (different failure domains).
- [ ] Installed in **visibility** mode first; DC stability validated
      before/after.
- [ ] Change-control ticket for installing software on a DC.

## Validation

- [ ] From an agentless domain-joined host, a known user's logon shows
      up as IP→user in CSW inventory.
- [ ] Mapping seen for hosts authenticated by **each** DC running the
      agent.
- [ ] Evidence exported (inventory JSON/CSV + screenshot) to the POV
      evidence folder.
