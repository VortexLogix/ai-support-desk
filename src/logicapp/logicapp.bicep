param location string
param name string
param billingEmail string
param technicalEmail string
param generalEmail string

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
        billingEmail: {
          type: 'String'
          defaultValue: billingEmail
        }
        technicalEmail: {
          type: 'String'
          defaultValue: technicalEmail
        }
        generalEmail: {
          type: 'String'
          defaultValue: generalEmail
        }
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
              required: [
                'ticketId'
                'category'
                'title'
              ]
            }
          }
        }
      }
      actions: {
        Route_by_category: {
          type: 'Switch'
          expression: '@triggerBody()?[\'category\']'
          cases: {
            Billing: {
              case: 'Billing'
              actions: {
                Send_Billing_Email: {
                  type: 'ApiConnection'
                  inputs: {
                    host: {
                      connection: {
                        name: '@parameters(\'$connections\')[\'gmail\'][\'connectionId\']'
                      }
                    }
                    method: 'post'
                    path: '/Mail'
                    body: {
                      To: '@parameters(\'billingEmail\')'
                      Subject: '[Billing] New ticket: @{triggerBody()?[\'title\']}'
                      Body: 'A new Billing ticket has been submitted.<br/><br/><b>Ticket ID:</b> @{triggerBody()?[\'ticketId\']}<br/><b>Title:</b> @{triggerBody()?[\'title\']}'
                    }
                  }
                }
              }
            }
            Technical: {
              case: 'Technical'
              actions: {
                Send_Technical_Email: {
                  type: 'ApiConnection'
                  inputs: {
                    host: {
                      connection: {
                        name: '@parameters(\'$connections\')[\'gmail\'][\'connectionId\']'
                      }
                    }
                    method: 'post'
                    path: '/Mail'
                    body: {
                      To: '@parameters(\'technicalEmail\')'
                      Subject: '[Technical] New ticket: @{triggerBody()?[\'title\']}'
                      Body: 'A new Technical ticket has been submitted.<br/><br/><b>Ticket ID:</b> @{triggerBody()?[\'ticketId\']}<br/><b>Title:</b> @{triggerBody()?[\'title\']}'
                    }
                  }
                }
              }
            }
          }
          default: {
            actions: {
              Send_General_Email: {
                type: 'ApiConnection'
                inputs: {
                  host: {
                    connection: {
                      name: '@parameters(\'$connections\')[\'gmail\'][\'connectionId\']'
                    }
                  }
                  method: 'post'
                  path: '/Mail'
                  body: {
                    To: '@parameters(\'generalEmail\')'
                    Subject: '[General] New ticket: @{triggerBody()?[\'title\']}'
                    Body: 'A new support ticket has been submitted.<br/><br/><b>Ticket ID:</b> @{triggerBody()?[\'ticketId\']}<br/><b>Title:</b> @{triggerBody()?[\'title\']}'
                  }
                }
              }
            }
          }
          runAfter: {}
        }
        Response: {
          type: 'Response'
          inputs: {
            statusCode: 200
            body: {
              status: 'routed'
            }
          }
          runAfter: {
            Route_by_category: [
              'Succeeded'
              'Skipped'
            ]
          }
        }
      }
      outputs: {}
    }
  }
}

output logicAppName string = logicApp.name
output triggerUrl string = logicApp.properties.accessEndpoint
