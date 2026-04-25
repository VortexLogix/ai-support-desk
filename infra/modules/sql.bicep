param location string
param serverName string
param databaseName string
param adminLogin string
@secure()
param adminPassword string
param skuName string
param skuTier string
param autoPauseDelay int
param minCapacity int

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    minimalTlsVersion: '1.2'
  }
}

resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    autoPauseDelay: autoPauseDelay
    minCapacity: json(string(minCapacity))
  }
}

@description('SQL connection string without password (password must be added by the caller)')
output connectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};Persist Security Info=False;User ID=${adminLogin};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
output serverFqdn string = sqlServer.properties.fullyQualifiedDomainName
