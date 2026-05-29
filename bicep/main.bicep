targetScope = 'subscription'

param location string = 'eastus'
param environment string = 'lab'
param projectName string = 'LandingZone'
param ownerName string = 'Adrian'
param keyVaultName string
param adminObjectId string = ''
param miPrincipalId string = ''

var tags = {
  Environment: environment
  Project: projectName
  Owner: ownerName
}

resource rgHub 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-lab-hub'
  location: location
  tags: tags
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-lab-spoke'
  location: location
  tags: tags
}

module hubNetwork 'modules/network-hub.bicep' = {
  name: 'deploy-hub-network'
  scope: rgHub
  params: {
    location: location
    tags: tags
  }
}

module spokeNetwork 'modules/network-spoke.bicep' = {
  name: 'deploy-spoke-network'
  scope: rgSpoke
  params: {
    location: location
    tags: tags
  }
}

module peeringHubToSpoke 'modules/peering.bicep' = {
  name: 'deploy-peering-hub-to-spoke'
  scope: rgHub
  params: {
    localVnetName: hubNetwork.outputs.vnetName
    remoteVnetId: spokeNetwork.outputs.vnetId
    peeringName: 'peer-hub-to-spoke'
  }
}

module peeringSpokeToHub 'modules/peering.bicep' = {
  name: 'deploy-peering-spoke-to-hub'
  scope: rgSpoke
  params: {
    localVnetName: spokeNetwork.outputs.vnetName
    remoteVnetId: hubNetwork.outputs.vnetId
    peeringName: 'peer-spoke-to-hub'
  }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'deploy-keyvault'
  scope: rgHub
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
    adminObjectId: adminObjectId
    miPrincipalId: miPrincipalId
  }
}

output hubVnetId string = hubNetwork.outputs.vnetId
output spokeVnetId string = spokeNetwork.outputs.vnetId
output keyVaultId string = keyVault.outputs.keyVaultId
