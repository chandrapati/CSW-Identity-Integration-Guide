#!/usr/bin/env bash
#
# Build .docx deliverables from the Markdown sources for customer hand-off.
# Requires: pandoc (https://pandoc.org). A reference .docx is optional.
#
# Usage:
#   ./docs/_build/build_docx.sh            # build all integration guides
#   ./docs/_build/build_docx.sh single FILE.md
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${REPO_ROOT}/docs/_build/out"
REF_DOCX="${REPO_ROOT}/docs/_build/reference.docx"   # optional template

command -v pandoc >/dev/null || {
  echo "pandoc not found. Install it: https://pandoc.org/installing.html" >&2
  exit 1
}

mkdir -p "${OUT_DIR}"

pandoc_opts=(--from gfm --toc --toc-depth=3 --standalone)
[[ -f "${REF_DOCX}" ]] && pandoc_opts+=(--reference-doc "${REF_DOCX}")

build_one() {
  local src="$1"
  local base
  base="$(basename "${src%.md}")"
  echo ">> ${src} -> ${OUT_DIR}/${base}.docx"
  pandoc "${pandoc_opts[@]}" "${src}" -o "${OUT_DIR}/${base}.docx"
}

if [[ "${1:-}" == "single" && -n "${2:-}" ]]; then
  build_one "${2}"
  exit 0
fi

# Default: the customer-facing integration + validation guides
MD_FILES=(
  "${REPO_ROOT}/active-directory/01-identity-connector-ad.md"
  "${REPO_ROOT}/active-directory/02-openldap-connector.md"
  "${REPO_ROOT}/active-directory/03-external-auth-ldap-rbac.md"
  "${REPO_ROOT}/entra-id/01-app-registration-graph-permissions.md"
  "${REPO_ROOT}/entra-id/02-entra-id-connector.md"
  "${REPO_ROOT}/entra-id/03-sign-in-logs-user-mapping.md"
  "${REPO_ROOT}/ad-agent/01-domain-controller-user-identity.md"
  "${REPO_ROOT}/validation/01-pov-test-plan.md"
  "${REPO_ROOT}/validation/02-evidence-matrix.md"
  "${REPO_ROOT}/validation/03-user-based-policy-examples.md"
  "${REPO_ROOT}/validation/04-adoption-runbook.md"
)

for f in "${MD_FILES[@]}"; do
  [[ -f "${f}" ]] && build_one "${f}"
done

echo "Done. Output in ${OUT_DIR}"
