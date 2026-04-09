@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name')
@allowed(['dev', 'qa', 'uat', 'prod'])
param environment string

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

// ── Environment Configuration ─────────────────────────────────────────────────

module envConfig 'modules/config.bicep' = {
  name: 'envConfig'
  params: {
    environment: environment
    location: location
  }
}

// ── Modules ───────────────────────────────────────────────────────────────────

module appInsights 'modules/appinsights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    name: envConfig.outputs.names.appInsights
    workspaceName: envConfig.outputs.names.logAnalyticsWorkspace
    logAnalyticsSkuName: envConfig.outputs.settings.logAnalytics.skuName
    retentionInDays: envConfig.outputs.settings.logAnalytics.retentionInDays
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    serverName: envConfig.outputs.names.sqlServer
    databaseName: envConfig.outputs.names.sqlDatabase
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
    skuName: envConfig.outputs.settings.sql.skuName
    skuTier: envConfig.outputs.settings.sql.skuTier
    autoPauseDelay: envConfig.outputs.settings.sql.autoPauseDelay
    minCapacity: envConfig.outputs.settings.sql.minCapacity
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'serviceBus'
  params: {
    location: location
    namespaceName: envConfig.outputs.names.serviceBusNamespace
    queueName: 'tickets'
    skuName: envConfig.outputs.settings.serviceBus.skuName
    skuTier: envConfig.outputs.settings.serviceBus.skuTier
    lockDuration: envConfig.outputs.settings.serviceBus.lockDuration
    maxDeliveryCount: envConfig.outputs.settings.serviceBus.maxDeliveryCount
  }
}

module openAi 'modules/openai.bicep' = {
  name: 'openAi'
  params: {
    location: location
    accountName: envConfig.outputs.names.openAiAccount
    deploymentName: openAiDeploymentName
    skuName: envConfig.outputs.settings.openAi.skuName
    deploymentCapacity: envConfig.outputs.settings.openAi.deploymentCapacity
  }
}

// ── Derived variables ─────────────────────────────────────────────────────────

var sqlConnectionString = '${sql.outputs.connectionString}Password=${sqlAdminPassword};'

// ── Modules (dependent on SQL) ────────────────────────────────────────────────

module appService 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    planName: envConfig.outputs.names.appServicePlan
    webAppName: envConfig.outputs.names.webApp
    sqlConnectionString: sqlConnectionString
    serviceBusConnectionString: serviceBus.outputs.connectionString
    jwtSecret: jwtSecret
    appInsightsConnectionString: appInsights.outputs.connectionString
    planSkuName: envConfig.outputs.settings.appServicePlan.skuName
    planSkuTier: envConfig.outputs.settings.appServicePlan.skuTier
  }
}

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebApp'
  params: {
    location: location
    name: envConfig.outputs.names.staticWebApp
    skuName: envConfig.outputs.settings.staticWebApp.skuName
    skuTier: envConfig.outputs.settings.staticWebApp.skuTier
  }
}

module functions 'modules/functions.bicep' = {
  name: 'functions'
  params: {
    location: location
    planName: envConfig.outputs.names.functionPlan
    functionAppName: envConfig.outputs.names.functionApp
    storageAccountName: envConfig.outputs.names.storageAccount
    sqlConnectionString: sqlConnectionString
    serviceBusConnectionString: serviceBus.outputs.connectionString
    openAiEndpoint: openAi.outputs.endpoint
    openAiKey: openAi.outputs.key
    openAiDeploymentName: openAiDeploymentName
    appInsightsConnectionString: appInsights.outputs.connectionString
    planSkuName: envConfig.outputs.settings.functionPlan.skuName
    planSkuTier: envConfig.outputs.settings.functionPlan.skuTier
    storageSkuName: envConfig.outputs.settings.storage.skuName
  }
}

module logicApp '../src/logicapp/logicapp.bicep' = {
  name: 'logicApp'
  params: {
    location: location
    name: envConfig.outputs.names.logicApp
    billingEmail: envConfig.outputs.settings.logicApp.billingEmail
    technicalEmail: envConfig.outputs.settings.logicApp.technicalEmail
    generalEmail: envConfig.outputs.settings.logicApp.generalEmail
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────
output apiUrl string = appService.outputs.url
output staticWebAppUrl string = staticWebApp.outputs.url
output functionAppName string = envConfig.outputs.names.functionApp
output webAppName string = envConfig.outputs.names.webApp
output staticWebAppName string = envConfig.outputs.names.staticWebApp
