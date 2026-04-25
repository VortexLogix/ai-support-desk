param location string
param name string
param skuName string
param skuTier string

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: name
  location: location
  sku: { name: skuName, tier: skuTier }
  properties: {}
}

output url string = 'https://${staticWebApp.properties.defaultHostname}'
output name string = staticWebApp.name
