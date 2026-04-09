using '../main.bicep'

param environment = 'qa'
param location = 'eastus'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = '<replace-with-qa-password>'
param jwtSecret = '<replace-with-qa-jwt-secret-32-chars>'
param openAiDeploymentName = 'gpt-4o'
