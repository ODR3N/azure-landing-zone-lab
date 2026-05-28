// peering.bicep 
// Creates a single-direction VNet peering 
// Must be deployed twice (once per direction) 
 
param localVnetName string 
param remoteVnetId string 
param peeringName string 
 
resource localVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = { 
  name: localVnetName 
} 
 
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = { 
  parent: localVnet 
  name: peeringName 
  properties: { 
    remoteVirtualNetwork: { id: remoteVnetId } 
    allowVirtualNetworkAccess: true 
    allowForwardedTraffic: true 
    allowGatewayTransit: false 
    useRemoteGateways: false 
  } 
} 
