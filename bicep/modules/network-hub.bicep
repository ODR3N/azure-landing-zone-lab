// network-hub.bicep 
// Deploys the hub VNet with Bastion and shared services subnets 
 
param location string = resourceGroup().location 
param vnetName string = 'vnet-hub' 
param vnetAddressPrefix string = '10.0.0.0/16' 
param bastionSubnetPrefix string = '10.0.0.0/27' 
param sharedSubnetPrefix string = '10.0.1.0/24' 
param bastionPublicIpName string = 'pip-bastion' 
param bastionName string = 'bastion-hub' 
param tags object = {} 
 
// Hub Virtual Network 
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = { 
  name: vnetName 
  location: location 
  tags: tags 
  properties: { 
    addressSpace: { 
      addressPrefixes: [vnetAddressPrefix] 
    } 
    subnets: [ 
      { 
        // Bastion MUST use this exact name 
        name: 'AzureBastionSubnet' 
        properties: { 
          addressPrefix: bastionSubnetPrefix 
          // No NSG on Bastion subnet — Azure manages Bastion's security internally 
        } 
      } 
      { 
        name: 'snet-shared' 
        properties: { 
          addressPrefix: sharedSubnetPrefix 
        } 
      } 
    ] 
  } 
} 
 
// Public IP for Bastion (Standard SKU required) 
resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = { 
  name: bastionPublicIpName 
  location: location 
  tags: tags 
  sku: { name: 'Standard' } 
  properties: { 
    publicIPAllocationMethod: 'Static' 
  } 
} 
 
// Azure Bastion host 
resource bastion 'Microsoft.Network/bastionHosts@2023-04-01' = { 
  name: bastionName 
  location: location 
  tags: tags 
  sku: { name: 'Basic' } 
  properties: { 
    ipConfigurations: [ 
      { 
        name: 'ipconfig1' 
        properties: { 
          subnet: { 
            id: '${hubVnet.id}/subnets/AzureBastionSubnet' 
          } 
          publicIPAddress: { 
            id: bastionPublicIp.id 
          } 
        } 
      } 
    ] 
  } 
} 
 
// Outputs — expose values that other modules need 
output vnetId string = hubVnet.id 
output vnetName string = hubVnet.name 
output sharedSubnetId string = hubVnet.properties.subnets[1].id
