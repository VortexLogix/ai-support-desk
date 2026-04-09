// ═══════════════════════════════════════════════════════════════════════════════
// config.bicep — AI Support Desk
// Centralized environment-specific configuration:
//   • Resource naming (following {envPrefix}-{locationShort}-{component}-{type})
//   • SKUs, tiers, capacities per environment
// ═══════════════════════════════════════════════════════════════════════════════

@description('Environment name')
@allowed(['dev', 'qa', 'uat', 'prod'])
param environment string

@description('Azure region (used to derive location short code)')
param location string

// ── Derived naming variables ───────────────────────────────────────────────

var envPrefixMap = {
  dev: 'd'
  qa: 'q'
  uat: 'u'
  prod: 'p'
}

var locationShortMap = {
  eastus: 'az1'
  eastus2: 'az2'
  westus: 'wz1'
  westus2: 'wz2'
  centralus: 'cz1'
  westeurope: 'we1'
  northeurope: 'ne1'
}

var envPrefix = envPrefixMap[environment]
var locationShort = locationShortMap[?location] ?? 'az1'
var component = 'aisd'
var namingPrefix = '${envPrefix}-${locationShort}-${component}'

// ── Resource Names ─────────────────────────────────────────────────────────

var resourceNames = {
  resourceGroup: '${namingPrefix}-rg'
  appInsights: '${namingPrefix}-ai'
  logAnalyticsWorkspace: '${namingPrefix}-law'
  sqlServer: '${namingPrefix}-sql'
  sqlDatabase: 'AiSupportDesk'
  serviceBusNamespace: '${namingPrefix}-sb'
  openAiAccount: '${namingPrefix}-oai'
  appServicePlan: '${namingPrefix}-plan'
  webApp: '${namingPrefix}-api'
  staticWebApp: '${namingPrefix}-swa'
  functionPlan: '${namingPrefix}-fnplan'
  functionApp: '${namingPrefix}-fn'
  storageAccount: '${envPrefix}${locationShort}${component}st'
  logicApp: '${namingPrefix}-la'
}

// ── Per-environment deployment configuration ───────────────────────────────

var envConfig = {
  dev: {
    appServicePlan: {
      skuName: 'B1'
      skuTier: 'Basic'
    }
    functionPlan: {
      skuName: 'Y1'
      skuTier: 'Dynamic'
    }
    sql: {
      skuName: 'GP_S_Gen5_1'
      skuTier: 'GeneralPurpose'
      autoPauseDelay: 60
      minCapacity: 1
    }
    serviceBus: {
      skuName: 'Standard'
      skuTier: 'Standard'
      lockDuration: 'PT5M'
      maxDeliveryCount: 5
    }
    openAi: {
      skuName: 'S0'
      deploymentCapacity: 10
    }
    storage: {
      skuName: 'Standard_LRS'
    }
    staticWebApp: {
      skuName: 'Free'
      skuTier: 'Free'
    }
    logAnalytics: {
      skuName: 'PerGB2018'
      retentionInDays: 30
    }
    logicApp: {
      billingEmail: 'billing-team@company.com'
      technicalEmail: 'tech-team@company.com'
      generalEmail: 'support@company.com'
    }
  }
  qa: {
    appServicePlan: {
      skuName: 'B1'
      skuTier: 'Basic'
    }
    functionPlan: {
      skuName: 'Y1'
      skuTier: 'Dynamic'
    }
    sql: {
      skuName: 'GP_S_Gen5_1'
      skuTier: 'GeneralPurpose'
      autoPauseDelay: 60
      minCapacity: 1
    }
    serviceBus: {
      skuName: 'Standard'
      skuTier: 'Standard'
      lockDuration: 'PT5M'
      maxDeliveryCount: 5
    }
    openAi: {
      skuName: 'S0'
      deploymentCapacity: 10
    }
    storage: {
      skuName: 'Standard_LRS'
    }
    staticWebApp: {
      skuName: 'Free'
      skuTier: 'Free'
    }
    logAnalytics: {
      skuName: 'PerGB2018'
      retentionInDays: 30
    }
    logicApp: {
      billingEmail: 'billing-qa@company.com'
      technicalEmail: 'tech-qa@company.com'
      generalEmail: 'support-qa@company.com'
    }
  }
  uat: {
    appServicePlan: {
      skuName: 'S1'
      skuTier: 'Standard'
    }
    functionPlan: {
      skuName: 'Y1'
      skuTier: 'Dynamic'
    }
    sql: {
      skuName: 'GP_S_Gen5_1'
      skuTier: 'GeneralPurpose'
      autoPauseDelay: 60
      minCapacity: 1
    }
    serviceBus: {
      skuName: 'Standard'
      skuTier: 'Standard'
      lockDuration: 'PT5M'
      maxDeliveryCount: 10
    }
    openAi: {
      skuName: 'S0'
      deploymentCapacity: 20
    }
    storage: {
      skuName: 'Standard_LRS'
    }
    staticWebApp: {
      skuName: 'Free'
      skuTier: 'Free'
    }
    logAnalytics: {
      skuName: 'PerGB2018'
      retentionInDays: 60
    }
    logicApp: {
      billingEmail: 'billing-uat@company.com'
      technicalEmail: 'tech-uat@company.com'
      generalEmail: 'support-uat@company.com'
    }
  }
  prod: {
    appServicePlan: {
      skuName: 'P1v3'
      skuTier: 'PremiumV3'
    }
    functionPlan: {
      skuName: 'EP1'
      skuTier: 'ElasticPremium'
    }
    sql: {
      skuName: 'GP_Gen5_2'
      skuTier: 'GeneralPurpose'
      autoPauseDelay: -1
      minCapacity: 2
    }
    serviceBus: {
      skuName: 'Premium'
      skuTier: 'Premium'
      lockDuration: 'PT5M'
      maxDeliveryCount: 10
    }
    openAi: {
      skuName: 'S0'
      deploymentCapacity: 40
    }
    storage: {
      skuName: 'Standard_GRS'
    }
    staticWebApp: {
      skuName: 'Standard'
      skuTier: 'Standard'
    }
    logAnalytics: {
      skuName: 'PerGB2018'
      retentionInDays: 90
    }
    logicApp: {
      billingEmail: 'billing@company.com'
      technicalEmail: 'tech@company.com'
      generalEmail: 'support@company.com'
    }
  }
}

// ── Outputs ────────────────────────────────────────────────────────────────

output names object = resourceNames
output settings object = envConfig[environment]
