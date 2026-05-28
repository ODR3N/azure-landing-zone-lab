// keyvault.bicep 
// Deploys Key Vault with RBAC authorization 
 
param keyVaultName string 
param location string = resourceGroup().location 
param tags object = {} 
 
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = { 
  name: keyVaultName 
  location: location 
  tags: tags 
  properties: { 
    sku: { family: 'A', name: 'standard' } 
    tenantId: subscription().tenantId 
    enableRbacAuthorization: true  // Use RBAC, not vault access policies 
    enableSoftDelete: true         // Deleted secrets recoverable for 90 days 
    softDeleteRetentionInDays: 90 
    enabledForDeployment: false    // VMs cannot read certs for VM deployment 
    enabledForTemplateDeployment: false 
    enabledForDiskEncryption: false 
    networkAcls: {                 // Public access enabled for lab simplicity 
      defaultAction: 'Allow' 
      bypass: 'AzureServices' 
    } 
  } 
} 
 
output keyVaultId string = keyVault.id 
output keyVaultName string = keyVault.name 
output keyVaultUri string = keyVault.properties.vaultUri
