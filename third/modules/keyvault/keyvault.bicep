param keyVaultName string
param location string
param objectId string = 'aeed2dc9-5fb9-4fba-9453-e21d91fcfff9'
@secure()
param keyVaultSecret string

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
          ]
          
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
  }

}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01'= {
  parent: keyVault
  name: 'vmAdminPassword'
  properties: {
    value: keyVaultSecret
  }
  
}

output keyVaultId string = keyVault.id
output secretId string = secret.id
