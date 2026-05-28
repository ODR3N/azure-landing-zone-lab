#!/bin/bash
# set-vars.sh — Load all session variables for azure-landing-zone-lab
# Usage: source ~/azure-landing-zone-lab/scripts/set-vars.sh

# ── Static values ────────────────────────────────────────────────────────────
export SUB_ID="1039a64d-60e5-4b98-87c1-7db60244f4ee"
export KV_NAME="kv-lab-odr3nvault"
export VM_ADMIN="azureuser"

# ── Derived static (built from SUB_ID, no CLI call needed) ───────────────────
export KV_ID="/subscriptions/$SUB_ID/resourceGroups/rg-lab-hub/providers/Microsoft.KeyVault/vaults/$KV_NAME"

# ── Resource Group scopes ────────────────────────────────────────────────────
export HUB_RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-lab-hub"
export SPOKE_RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/rg-lab-spoke"
export SUB_SCOPE="/subscriptions/$SUB_ID"

# ── Network ──────────────────────────────────────────────────────────────────
export HUB_ID=$(az network vnet show \
  --name vnet-hub \
  --resource-group rg-lab-hub \
  --query id --output tsv | tr -d '\r')

export SPOKE_ID=$(az network vnet show \
  --name vnet-spoke \
  --resource-group rg-lab-spoke \
  --query id --output tsv | tr -d '\r')

export SUBNET_ID=$(az network vnet subnet show \
  --name snet-app \
  --resource-group rg-lab-spoke \
  --vnet-name vnet-spoke \
  --query id --output tsv | tr -d '\r')

# ── Key Vault ─────────────────────────────────────────────────────────────────
export LAW_ID=$(az monitor log-analytics workspace show \
  --workspace-name law-hub \
  --resource-group rg-lab-hub \
  --query id --output tsv | tr -d '\r')

export LAW_CUSTOMER_ID=$(az monitor log-analytics workspace show \
  --workspace-name law-hub \
  --resource-group rg-lab-hub \
  --query customerId --output tsv | tr -d '\r')

export LAW_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --workspace-name law-hub \
  --resource-group rg-lab-hub \
  --query primarySharedKey --output tsv | tr -d '\r')

# ── Managed Identity ─────────────────────────────────────────────────────────
export MI_ID=$(az identity show \
  --name mi-app-vm \
  --resource-group rg-lab-spoke \
  --query id --output tsv | tr -d '\r')

export MI_PRINCIPAL_ID=$(az identity show \
  --name mi-app-vm \
  --resource-group rg-lab-spoke \
  --query principalId --output tsv | tr -d '\r')

# ── Virtual Machine ───────────────────────────────────────────────────────────
export VM_ID=$(az vm show \
  --name vm-app-01 \
  --resource-group rg-lab-spoke \
  --query id --output tsv | tr -d '\r')

# ── Monitor ───────────────────────────────────────────────────────────────────
export AG_ID=$(az monitor action-group show \
  --name ag-lab-ops \
  --resource-group rg-lab-spoke \
  --query id --output tsv | tr -d '\r')

# ── Current user OID (bypasses Graph API) ────────────────────────────────────
export MY_OID=$(az account get-access-token \
  --query accessToken --output tsv | tr -d '\r' | \
  python3 -c "
import sys, base64, json
token = sys.stdin.read().strip().split('.')[1]
token += '=' * (4 - len(token) % 4)
print(json.loads(base64.b64decode(token))['oid'])
")

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ Variables loaded for azure-landing-zone-lab"
echo "────────────────────────────────────────────────"
echo "  SUB_ID:          $SUB_ID"
echo "  KV_NAME:         $KV_NAME"
echo "  KV_ID:           $KV_ID"
echo "  HUB_RG_SCOPE:    $HUB_RG_SCOPE"
echo "  SPOKE_RG_SCOPE:  $SPOKE_RG_SCOPE"
echo "  HUB_ID:          $HUB_ID"
echo "  SPOKE_ID:        $SPOKE_ID"
echo "  SUBNET_ID:       $SUBNET_ID"
echo "  LAW_ID:          $LAW_ID"
echo "  LAW_CUSTOMER_ID: $LAW_CUSTOMER_ID"
echo "  MI_ID:           $MI_ID"
echo "  MI_PRINCIPAL_ID: $MI_PRINCIPAL_ID"
echo "  VM_ID:           $VM_ID"
echo "  AG_ID:           $AG_ID"
echo "  MY_OID:          $MY_OID"
echo "────────────────────────────────────────────────"
echo ""
