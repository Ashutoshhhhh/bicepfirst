//module vnet
param vnetName string 
param vnetAddressSpace string
param subnetName array
param subnetAddressPrefix array
param location string

module vnet 'modules/network/vnet.bicep' ={
  name: 'vnet-${vnetName}'
  params : {
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
    location: location
  }
}
//module asg
param asgName array 

module asg 'modules/network/asg.bicep'= {
  name: 'asg-${vnetName}'
  params: {
    asgName: asgName
    location: location

  }
}
//module nsg

param nsgName array
param tier array
var asgIds object = {
  app: asg.outputs.asgIds[0]
  web: asg.outputs.asgIds[1]
  db: asg.outputs.asgIds[2]
}

module nsgforsubnet 'modules/network/nsg-subnets.bicep' = [
  for i in range(0, length(nsgName)):{
    name: 'nsg-${nsgName[i]}'
    params:{
      nsgName: nsgName[i]
      location: location
      tier: tier[i]
      asgIds:asgIds
    }
  }
]

resource nsgsubnetassociation 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [
  for i in range(0, length(nsgName)):{
    name: '${vnetName}/${subnetName[i]}'
    properties: {
      addressPrefix: subnetAddressPrefix[i]
      networkSecurityGroup:{
        id: nsgforsubnet[i].outputs.nsgId[0]
      }
    }
  }
]

// module keyvault 

// param objectId string
// @secure()
// param keyVaultSecret string 
// module keyvault 'modules/keyvault/keyvault.bicep' = {
//   name: 'keyvault-${keyVaultName}'
//   params: {
//     keyVaultName: keyVaultName
//     location: location
//     objectId: objectId
//     keyVaultSecret: keyVaultSecret
//   }
// }

//module nsg for vm
param nsgForVmName array

module nsgforvm 'modules/network/nsg-vm.bicep'= [
  for i in range(0, length(nsgForVmName)):{
    name: 'nsg-vm-${nsgForVmName[i]}'
    params: {
      nsgForVmName: nsgForVmName[i]
      location: location
      tier: tier[i]
      asgIds: asgIds
    }
  }
]
param keyVaultName string = 'ashukey7222'
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing={
  name: keyVaultName

}

// var vmAdminPassword = listSecret(keyVault.id, '2022-07-01').value
param vmName array
param vmSize string
param admin string
param zones string
param publicIp array
var asgId array = [asg.outputs.asgIds[0], asg.outputs.asgIds[1], asg.outputs.asgIds[2]]
var subnetIds array = [vnet.outputs.subnetIds[0], vnet.outputs.subnetIds[1], vnet.outputs.subnetIds[2]]
var nsgIdsForVm array = [nsgforvm[0].outputs.nsgIds[0], nsgforvm[1].outputs.nsgIds[0], nsgforvm[2].outputs.nsgIds[0]]
module vms 'modules/compute/vm.bicep' = [
  for i in range(0, length(vmName)): {
    name: 'vm-${vmName[i]}'
    params: {
      vmName: vmName[i]
      location: location
      vmSize: vmSize
      admin: admin
      zones: zones
      publicIp: publicIp[i]
      asgIds: asgId[i]
      subnetId: subnetIds[i]
      nsgId: nsgIdsForVm[i]
      adminPassword: keyVault.getSecret('vmAdminPassword')

    }
  }
]
