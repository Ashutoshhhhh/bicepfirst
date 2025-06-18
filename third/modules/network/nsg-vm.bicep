param nsgForVmName string
param location string
param tier string
param asgIds object

resource nsgforvm 'Microsoft.Network/networkSecurityGroups@2024-07-01'= {
  name: nsgForVmName
  location: location
  properties: {
    securityRules: concat(
      tier == 'app' ? [
        {
          name: 'AllowInternetInbound'
          properties: {
            priority: 500
            direction: 'Inbound'
            access: 'Allow'
            protocol: 'TCP'
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgIds.app
              }
            ]
            destinationPortRanges: [22,80,443]
          }
        }
        {
          name: 'DenyVNetInbound'
          properties: {
            priority: 800
            direction: 'Inbound'
            access: 'Deny'
            protocol: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
          }
        }

      ]:[],
      tier == 'web'?[
        {
          name: 'AllowAppInbound'
          properties: {
            priority: 600
            direction: 'Inbound'
            access: 'Allow'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceApplicationSecurityGroups: [
              {
                id: asgIds.app
              }
            ]
            destinationApplicationSecurityGroups: [
              {
                id: asgIds.web
              }
            ]
            destinationPortRanges: [22,80,443]
          }

        }
        {
          name: 'DenyVNetInbound'
          properties: {
            priority: 800
            direction: 'Inbound'
            access: 'Deny'
            protocol: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
          }
        }


      ]:[],
      tier == 'db' ? [
        {
          name: 'AllowWebInbound'
          properties: {
            priority: 600
            direction: 'Inbound'
            access: 'Allow'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceApplicationSecurityGroups: [
              {
                id: asgIds.web
              }
            ]
            destinationApplicationSecurityGroups: [
              {
                id: asgIds.db
              }
            ]
            destinationPortRanges: [22,80,443]
          }
        }
        {
          name: 'DenyVNetInbound'
          properties: {
            priority: 800
            direction: 'Inbound'
            access: 'Deny'
            protocol: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
          }
        }


      ]:[]
    )
  }
}

output nsgIds array =[
  nsgforvm.id
  
]
