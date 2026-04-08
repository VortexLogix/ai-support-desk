param location string
param planName string
param functionAppName string
param storageAccountName string
param sqlConnectionString string
@secure()
param serviceBusConnectionString string
param openAiEndpoint string
@secure()
param openAiKey string
param openAiDeploymentName string
param appInsightsConnectionString string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  sku: { name: 'Y1', tier: 'Dynamic' }
  kind: 'functionapp'
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      netFrameworkVersion: 'v10.0'
      appSettings: [
        { name: 'AzureWebJobsStorage', value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}' }
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'dotnet-isolated' }
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsightsConnectionString }
        { name: 'ServiceBus__ConnectionString', value: serviceBusConnectionString }
        { name: 'ServiceBus__QueueName', value: 'tickets' }
        { name: 'SqlConnectionString', value: sqlConnectionString }
        { name: 'AzureOpenAi__Endpoint', value: openAiEndpoint }
        { name: 'AzureOpenAi__ApiKey', value: openAiKey }
        { name: 'AzureOpenAi__DeploymentName', value: openAiDeploymentName }
      ]
    }
    httpsOnly: true
  }
}

output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
