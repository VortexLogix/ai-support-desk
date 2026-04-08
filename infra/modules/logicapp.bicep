param location string
param name string
@description('Path to workflow.json relative to this module — used for reference only. Actual workflow is deployed via ARM template.')
param workflowDefinitionPath string = '../src/logicapp/workflow.json'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        billingEmail: { type: 'string', defaultValue: 'billing-team@company.com' }
        technicalEmail: { type: 'string', defaultValue: 'tech-team@company.com' }
        generalEmail: { type: 'string', defaultValue: 'support@company.com' }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              type: 'object'
              properties: {
                ticketId: { type: 'string' }
                category: { type: 'string' }
                title: { type: 'string' }
              }
            }
          }
        }
      }
      actions: {}
      outputs: {}
    }
  }
}

// Note: The full workflow definition including Gmail connector actions must be configured
// after deploying the Logic App and creating the API connection in the Azure portal.
// The workflow.json in src/logicapp/ contains the complete definition for reference.

output logicAppName string = logicApp.name
output triggerUrl string = logicApp.properties.accessEndpoint
