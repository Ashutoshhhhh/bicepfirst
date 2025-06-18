param location string
param nsgName string
param tier string
param asgIds object

resource nsgsubnets 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: concat(
      tier == 'app' ? [
        {
          name: 'AllowInternetInbound'
          properties:{
            priority: 600
            direction: 'Inbound'
            access: 'Allow'
            protocol: '*'
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationApplicationSecurityGroups: [
              {
                id: asgIds.app
              }
            ]
            destinationPortRange: '*'


          }
        }
      ]:[],
      tier == 'web' ? [
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
            destinationPortRange: '*'
          }

        }
      ]: [],
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
            destinationPortRange: '*'
          }
        }

      ]:[]
    )
  }
}

output nsgId array = [
  nsgsubnets.id
]
