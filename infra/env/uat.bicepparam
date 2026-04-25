using '../main.bicep'

param environment = 'uat'
param location = 'eastus'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = '<replace-with-uat-password>'
param jwtSecret = '<replace-with-uat-jwt-secret-32-chars>'
param openAiDeploymentName = 'gpt-4o'
