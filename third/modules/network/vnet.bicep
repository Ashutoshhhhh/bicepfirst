param vnetName string 
param vnetAddressSpace string
param subnetName array
param subnetAddressPrefix array
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location 
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      for i in range(0, length(subnetName)): {
        name: subnetName[i]
        properties: {
          addressPrefix: subnetAddressPrefix[i]
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetIds array = [
  for name in subnetName: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, name)
]
