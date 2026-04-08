param location string
param namespaceName string
param queueName string

resource namespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: namespace
  name: queueName
  properties: {
    lockDuration: 'PT5M'
    maxDeliveryCount: 5
  }
}

resource sendListenRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-10-01-preview' = {
  parent: namespace
  name: 'SendListen'
  properties: {
    rights: ['Send', 'Listen', 'Manage']
  }
}

output connectionString string = listKeys(sendListenRule.id, sendListenRule.apiVersion).primaryConnectionString
output namespaceName string = namespace.name
