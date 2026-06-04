# Validation — POV and adoption

Material to run an identity-integration **proof-of-value** and then take
it to **production adoption**.

| Doc | Use |
|---|---|
| [`01-pov-test-plan.md`](./01-pov-test-plan.md) | Phased test plan with pass/partial/fail criteria |
| [`02-evidence-matrix.md`](./02-evidence-matrix.md) | Requirement → evidence → scoring (copy/fill per engagement) |
| [`03-user-based-policy-examples.md`](./03-user-based-policy-examples.md) | Scopes, inventory filters, and policy expressed on identity labels |
| [`04-adoption-runbook.md`](./04-adoption-runbook.md) | Crawl → walk → run path to production |

## How this complements the CSW POV skills

This section is identity-specific. For the **overall** CSW POV structure
(phases, scoring model, enforcement validation with host log bundles),
use the broader toolkit:

- `csw-pov-validation` — POV phases, scoring, evidence routing.
- `csw-api` — live cluster queries (connectors, inventory, flows).
- `csw-logs-check` — host-side enforcement proof.

Customer-specific findings belong in the **customer POV repo**
(`{Customer}-CSW-POV/docs/integrations/identity/`), not in this reusable
guide. Keep this repo product-generic and anonymised.
