param vmName string
param vmSize string
param admin string
param location string
param zones string
param publicIp bool = false
param asgIds string
param subnetId string
param nsgId string
@secure()
param adminPassword string 

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' = if(publicIp) {
  name: '${vmName}-publicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    
  }
  sku: {
    name: 'Standard'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: publicIp ? {id:publicIP.id} : null
          applicationSecurityGroups: [
            {id: asgIds}
          ]
          
        }
      }
    ]
    networkSecurityGroup: {
            id: nsgId
          }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01'= {
  name: vmName
  location: location
  zones: [zones]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: admin
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
  
  networkProfile: {
    networkInterfaces: [
      {
        id: nic.id
      }
    ]
  }
}
}

