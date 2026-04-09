<#
.SYNOPSIS
    Deletes Azure resources in the specified resource group.

.DESCRIPTION
    Safely removes all resources from the target resource group.
    Uses a helper function that checks existence before deleting.
    Called by deploy-steps-template.yml when deleteAzureResources = 'Yes'.

.PARAMETER ResourceGroupName
    The name of the Azure resource group whose resources should be deleted.
    Expected format: {envPrefix}-{locationShort}-{component}-rg  (e.g., d-az1-aisd-rg)

.EXAMPLE
    .\Delete-AzureResource.ps1 -ResourceGroupName 'd-az1-aisd-rg'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

$ErrorActionPreference = 'Stop'

# ── Derive naming prefix from the resource group name ───────────────────────
# e.g., 'd-az1-aisd-rg' → prefix = 'd-az1-aisd-'
$parts = $ResourceGroupName -split '-'
$envPrefix = $parts[0]
$locationShort = $parts[1]
$component = $parts[2]
$resourcePrefix = "${envPrefix}-${locationShort}-${component}-"

Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "  Deleting resources in: $ResourceGroupName"
Write-Host "  Env prefix:            $envPrefix"
Write-Host "  Location short:        $locationShort"
Write-Host "  Resource prefix:       $resourcePrefix"
Write-Host "═══════════════════════════════════════════════════════════════"

# ── Helper function ─────────────────────────────────────────────────────────
function Remove-AzResourceIfExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$ResourceType
    )

    Write-Host "`n→ Checking: $ResourceType matching '$ResourceName' ..."

    $resources = Get-AzResource `
        -ResourceGroupName $ResourceGroupName `
        -ResourceType $ResourceType `
        -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $ResourceName }

    if ($resources -and $resources.Count -gt 0) {
        foreach ($resource in $resources) {
            Write-Host "  Found. Deleting '$($resource.Name)' ..."
            Remove-AzResource `
                -ResourceId $resource.ResourceId `
                -Force `
                -ErrorAction Stop
            Write-Host "  ✓ Deleted '$($resource.Name)'."
        }
    }
    else {
        Write-Host "  — Not found. Skipping."
    }
}

# ── Delete resources in dependency-safe order (leaf → root) ─────────────────

# 1. Logic App
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}la" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Logic/workflows'

# 2. Function App
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}fn" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Web/sites'

# 3. API App Service
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}api" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Web/sites'

# 4. Function App Service Plan
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}fnplan" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Web/serverfarms'

# 5. API App Service Plan
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}plan" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Web/serverfarms'

# 6. Static Web App
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}swa" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Web/staticSites'

# 7. Service Bus Namespace
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}sb" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.ServiceBus/namespaces'

# 8. Azure OpenAI Account
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}oai" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.CognitiveServices/accounts'

# 8. SQL Database (delete before server)
$sqlServers = Get-AzResource `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Sql/servers' `
    -ErrorAction SilentlyContinue

foreach ($sqlServer in $sqlServers) {
    $databases = Get-AzResource `
        -ResourceGroupName $ResourceGroupName `
        -ResourceType 'Microsoft.Sql/servers/databases' `
        -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$($sqlServer.Name)/*" -and $_.Name -notlike "*/master" }
    foreach ($db in $databases) {
        Write-Host "`n→ Deleting SQL database: $($db.Name) ..."
        Remove-AzResource -ResourceId $db.ResourceId -Force -ErrorAction Stop
        Write-Host "  ✓ Deleted '$($db.Name)'."
    }
}

# 9. SQL Server
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}sql" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Sql/servers'

# 10. Application Insights
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}ai" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Insights/components'

# 11. Log Analytics Workspace
Remove-AzResourceIfExists `
    -ResourceName "${resourcePrefix}law" `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.OperationalInsights/workspaces'

# 12. Storage Account (alphanumeric name: e.g., daz1aisdst)
$storagePrefix = "${envPrefix}${locationShort}${component}st"
$storageAccounts = Get-AzResource `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.Storage/storageAccounts' `
    -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "${storagePrefix}*" }

foreach ($sa in $storageAccounts) {
    Write-Host "`n→ Deleting storage account: $($sa.Name) ..."
    Remove-AzResource -ResourceId $sa.ResourceId -Force -ErrorAction Stop
    Write-Host "  ✓ Deleted '$($sa.Name)'."
}

Write-Host "`n═══════════════════════════════════════════════════════════════"
Write-Host "  Resource cleanup complete for: $ResourceGroupName"
Write-Host "═══════════════════════════════════════════════════════════════"
