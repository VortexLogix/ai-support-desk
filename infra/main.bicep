@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev or prod)')
@allowed(['dev', 'prod'])
param environment string

@description('Unique suffix appended to resource names')
param resourceSuffix string

@description('Azure SQL administrator login')
param sqlAdminLogin string

@secure()
@description('Azure SQL administrator password')
param sqlAdminPassword string

@description('JWT secret for the API')
@secure()
param jwtSecret string

@description('Azure OpenAI GPT-4o deployment name')
param openAiDeploymentName string = 'gpt-4o'

var prefix = 'aisd-${environment}'

// ── Modules ───────────────────────────────────────────────────────────────────

module appInsights 'modules/appinsights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    name: '${prefix}-ai-${resourceSuffix}'
    workspaceName: '${prefix}-law-${resourceSuffix}'
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    serverName: '${prefix}-sql-${resourceSuffix}'
    databaseName: 'AiSupportDesk'
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'serviceBus'
  params: {
    location: location
    namespaceName: '${prefix}-sb-${resourceSuffix}'
    queueName: 'tickets'
  }
}

module openAi 'modules/openai.bicep' = {
  name: 'openAi'
  params: {
    location: location
    accountName: '${prefix}-oai-${resourceSuffix}'
    deploymentName: openAiDeploymentName
  }
}

module appService 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    planName: '${prefix}-plan-${resourceSuffix}'
    webAppName: '${prefix}-api-${resourceSuffix}'
    sqlConnectionString: sql.outputs.connectionString
    serviceBusConnectionString: serviceBus.outputs.connectionString
    jwtSecret: jwtSecret
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebApp'
  params: {
    location: location
    name: '${prefix}-swa-${resourceSuffix}'
  }
}

module functions 'modules/functions.bicep' = {
  name: 'functions'
  params: {
    location: location
    planName: '${prefix}-fnplan-${resourceSuffix}'
    functionAppName: '${prefix}-fn-${resourceSuffix}'
    storageAccountName: 'aisd${environment}st${resourceSuffix}'
    sqlConnectionString: sql.outputs.connectionString
    serviceBusConnectionString: serviceBus.outputs.connectionString
    openAiEndpoint: openAi.outputs.endpoint
    openAiKey: openAi.outputs.key
    openAiDeploymentName: openAiDeploymentName
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

module logicApp 'modules/logicapp.bicep' = {
  name: 'logicApp'
  params: {
    location: location
    name: '${prefix}-la-${resourceSuffix}'
    workflowDefinitionPath: '../src/logicapp/workflow.json'
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────
output apiUrl string = appService.outputs.url
output staticWebAppUrl string = staticWebApp.outputs.url
output functionAppName string = functions.outputs.functionAppName
