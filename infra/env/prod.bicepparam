using '../main.bicep'

param environment = 'prod'
param location = 'eastus'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = '<inject-from-keyvault-in-pipeline>'
param jwtSecret = '<inject-from-keyvault-in-pipeline>'
param openAiDeploymentName = 'gpt-4o'
