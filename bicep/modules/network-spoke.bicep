// network-spoke.bicep 
// Deploys the spoke VNet with app and db subnets, NSGs, and NSG rules 
 
param location string = resourceGroup().location 
param vnetName string = 'vnet-spoke' 
param vnetAddressPrefix string = '10.1.0.0/16' 
param appSubnetPrefix string = '10.1.1.0/24' 
param dbSubnetPrefix string = '10.1.2.0/24' 
param bastionSubnetCidr string = '10.0.0.0/27' 
param tags object = {} 
 
// NSG for app subnet 
resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-04-01' = { 
  name: 'nsg-app' 
  location: location 
  tags: tags 
  properties: { 
    securityRules: [ 
      { 
        name: 'allow-ssh-from-bastion' 
        properties: { 
          priority: 100 
          direction: 'Inbound' 
          access: 'Allow' 
          protocol: 'Tcp' 
          sourceAddressPrefix: bastionSubnetCidr 
          sourcePortRange: '*' 
          destinationAddressPrefix: appSubnetPrefix 
          destinationPortRange: '22' 
        } 
      } 
      { 
        name: 'allow-http-inbound' 
        properties: { 
          priority: 110 
          direction: 'Inbound' 
          access: 'Allow' 
          protocol: 'Tcp' 
          sourceAddressPrefix: '*' 
          sourcePortRange: '*' 
          destinationAddressPrefix: '*' 
          destinationPortRange: '80' 
        } 
      } 
      { 
        name: 'allow-https-inbound' 
        properties: { 
          priority: 120 
          direction: 'Inbound' 
          access: 'Allow' 
          protocol: 'Tcp' 
          sourceAddressPrefix: '*' 
          sourcePortRange: '*' 
          destinationAddressPrefix: '*' 
          destinationPortRange: '443' 
        } 
      } 
    ] 
  } 
} 
 
// NSG for db subnet 
resource nsgDb 'Microsoft.Network/networkSecurityGroups@2023-04-01' = { 
  name: 'nsg-db' 
  location: location 
  tags: tags 
  properties: { 
    securityRules: [ 
      { 
        name: 'allow-app-to-db' 
        properties: { 
          priority: 100 
          direction: 'Inbound' 
          access: 'Allow' 
          protocol: 'Tcp' 
          sourceAddressPrefix: appSubnetPrefix 
          sourcePortRange: '*' 
          destinationAddressPrefix: '*' 
          destinationPortRange: '5432' 
        } 
      } 
      { 
        name: 'deny-internet-to-db' 
        properties: { 
          priority: 4000 
          direction: 'Inbound' 
          access: 'Deny' 
          protocol: '*' 
          sourceAddressPrefix: 'Internet' 
          sourcePortRange: '*' 
          destinationAddressPrefix: '*' 
          destinationPortRange: '*' 
        } 
      } 
    ] 
  } 
} 
 
// Spoke Virtual Network with subnets and NSG attachments 
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = { 
  name: vnetName 
  location: location 
  tags: tags 
  properties: { 
    addressSpace: { addressPrefixes: [vnetAddressPrefix] } 
    subnets: [ 
      { 
        name: 'snet-app' 
        properties: { 
          addressPrefix: appSubnetPrefix 
          networkSecurityGroup: { id: nsgApp.id } 
        } 
      } 
      { 
        name: 'snet-db' 
        properties: { 
          addressPrefix: dbSubnetPrefix 
          networkSecurityGroup: { id: nsgDb.id } 
        } 
      } 
    ] 
  } 
} 
 
output vnetId string = spokeVnet.id 
output vnetName string = spokeVnet.name 
output appSubnetId string = spokeVnet.properties.subnets[0].id 
output dbSubnetId string = spokeVnet.properties.subnets[1].id 
