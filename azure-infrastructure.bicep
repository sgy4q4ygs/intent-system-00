@description('User or Application ID.')
param identityPrincipalId string

@description('The SQL administrator password.')
@secure()
param sqlAdminPassword string

@description('The name of the storage account.')
param storageAccountName string = 'intentsystem00storage'

@description('The name of the SQL server.')
param sqlServerName string = 'intent-system-00-sqlserver'

@description('The name of the SQL database.')
param sqlDatabaseName string = 'intent-system-00-sql-db'

@description('The SQL administrator login username.')
param sqlAdminLogin string = 'adminuser'

@description('The name of the Key Vault.')
param keyVaultName string = 'intent-system-00-vault'

@description('The Azure region where resources will be created.')
param location string = resourceGroup().location

// Azure Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

// Firewall rule to allow Azure services to access the SQL server
resource allowAzureIPs 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'AllowAllAzureIPs'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Azure SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
    sampleName: 'AdventureWorksLT' // Optional: Remove if you don't want the sample database
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'intent-system-00-service-plan'
  location: resourceGroup().location
  sku: {
    name: 'Y1' // Consumption Plan (scale-to-zero)
    tier: 'Dynamic'
  }
}

// Azure Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
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
        objectId: identityPrincipalId
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
  }
}

// Store Storage Account Connection String in Key Vault
resource storageConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVault.name}/storageConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
  }
  dependsOn: [
    keyVault
    storageAccount
  ]
}

// Store SQL Admin Password in Key Vault
resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVault.name}/sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
  dependsOn: [
    keyVault
    sqlServer
  ]
}
