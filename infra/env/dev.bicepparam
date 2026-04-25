using '../main.bicep'

param environment = 'dev'
param location = 'eastus'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = '<replace-with-dev-password>'
param jwtSecret = '<replace-with-dev-jwt-secret-32-chars>'
param openAiDeploymentName = 'gpt-4o'
