param location string
param planName string
param webAppName string
param sqlConnectionString string
@secure()
param serviceBusConnectionString string
@secure()
param jwtSecret string
param appInsightsConnectionString string

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  sku: { name: 'B1', tier: 'Basic' }
  kind: 'linux'
  properties: { reserved: true }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: [
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsightsConnectionString }
        { name: 'Jwt__Issuer', value: 'ai-support-desk' }
        { name: 'Jwt__Audience', value: 'ai-support-desk-client' }
        { name: 'Jwt__Secret', value: jwtSecret }
        { name: 'ServiceBus__ConnectionString', value: serviceBusConnectionString }
        { name: 'ServiceBus__QueueName', value: 'tickets' }
      ]
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: sqlConnectionString
          type: 'SQLServer'
        }
      ]
    }
    httpsOnly: true
  }
}

output url string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
