#!/usr/bin/env bash
#
# Create the Entra ID app registration for the Cisco Secure Workload
# Identity Connector and grant the Microsoft Graph Application
# permissions it needs.
#
# SAFETY:
#   - This script does NOT print or persist any client secret.
#   - Prefer certificate auth over a client secret in production.
#   - Requires an Entra ID admin able to grant admin consent.
#
# Usage:
#   ./az-app-registration.sh "cisco-secure-workload-identity" [--with-signin-logs]
#
set -euo pipefail

APP_NAME="${1:-cisco-secure-workload-identity}"
WITH_SIGNIN_LOGS="false"
[[ "${2:-}" == "--with-signin-logs" ]] && WITH_SIGNIN_LOGS="true"

# Microsoft Graph resource appId (well-known, constant)
GRAPH_APP_ID="00000003-0000-0000-c000-000000000000"

# Application (app-only) permission IDs for Microsoft Graph.
# Verify against: https://learn.microsoft.com/graph/permissions-reference
DIRECTORY_READ_ALL="7ab1d382-f21e-4acd-a863-ba3e13f7da61"   # Directory.Read.All
GROUPMEMBER_READ_ALL="98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
USER_READ_ALL="df021288-bdef-4463-88db-98f22de89214"        # User.Read.All
AUDITLOG_READ_ALL="b0afded3-3588-46d8-8b3d-9842eff778da"    # AuditLog.Read.All

command -v az >/dev/null || { echo "az CLI not found. Install Azure CLI first." >&2; exit 1; }

echo ">> Creating app registration: ${APP_NAME}"
APP_ID="$(az ad app create --display-name "${APP_NAME}" --query appId -o tsv)"
echo "   ClientID (appId): ${APP_ID}"

TENANT_ID="$(az account show --query tenantId -o tsv)"
echo "   TenantID:         ${TENANT_ID}"

# Ensure a service principal exists for the app (needed for consent)
az ad sp create --id "${APP_ID}" >/dev/null 2>&1 || true

echo ">> Adding Microsoft Graph Application permissions"
az ad app permission add --id "${APP_ID}" --api "${GRAPH_APP_ID}" \
  --api-permissions "${DIRECTORY_READ_ALL}=Role" >/dev/null
az ad app permission add --id "${APP_ID}" --api "${GRAPH_APP_ID}" \
  --api-permissions "${GROUPMEMBER_READ_ALL}=Role" >/dev/null
az ad app permission add --id "${APP_ID}" --api "${GRAPH_APP_ID}" \
  --api-permissions "${USER_READ_ALL}=Role" >/dev/null

if [[ "${WITH_SIGNIN_LOGS}" == "true" ]]; then
  echo "   + AuditLog.Read.All (sign-in logs)"
  az ad app permission add --id "${APP_ID}" --api "${GRAPH_APP_ID}" \
    --api-permissions "${AUDITLOG_READ_ALL}=Role" >/dev/null
fi

echo ">> Granting admin consent (requires admin privileges)"
az ad app permission admin-consent --id "${APP_ID}"

cat <<EOF

==================================================================
App registration ready for the CSW Entra ID connector.

  TenantID : ${TENANT_ID}
  ClientID : ${APP_ID}

NEXT — create credentials (NOT done here on purpose):

  Option A (preferred) — certificate:
    Generate/obtain an RSA cert; private key must be UNENCRYPTED and
    PKCS1 or PKCS8. Upload the cert to the app:
      az ad app credential reset --id ${APP_ID} --create-cert
    Store the resulting key material in your vault.

  Option B — client secret (set short expiry, then vault it):
      az ad app credential reset --id ${APP_ID} --years 1
    Copy the printed secret into your vault immediately; it is shown
    once. Add a rotation reminder before expiry.

Then enter TenantID / ClientID / (secret|cert+key) in:
  Manage > Workloads > Connectors > Identity Connector > Entra ID
==================================================================
EOF
