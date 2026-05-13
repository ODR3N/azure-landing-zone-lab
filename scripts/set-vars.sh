export SUB_ID="1039a64d-60e5-4b98-87c1-7db60244f4ee"
export KV_NAME="kv-lab-odr3nvault"
export KV_ID="/subscriptions/$SUB_ID/resourceGroups/rg-lab-hub/providers/Microsoft.KeyVault/vaults/$KV_NAME"
export LAW_ID=$(az monitor log-analytics workspace show \
  --workspace-name law-hub \
  --resource-group rg-lab-hub \
  --query id --output tsv)
export HUB_ID=$(az network vnet show \
  --name vnet-hub \
  --resource-group rg-lab-hub \
  --query id --output tsv)
export SPOKE_ID=$(az network vnet show \
  --name vnet-spoke \
  --resource-group rg-lab-spoke \
  --query id --output tsv)

echo "Variables loaded:"
echo "  SUB_ID:   $SUB_ID"
echo "  KV_NAME:  $KV_NAME"
echo "  KV_ID:    $KV_ID"
echo "  LAW_ID:   $LAW_ID"
echo "  HUB_ID:   $HUB_ID"
echo "  SPOKE_ID: $SPOKE_ID"
