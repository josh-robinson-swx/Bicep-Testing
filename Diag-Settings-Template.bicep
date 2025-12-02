targetScope = 'subscription'

@description('Log Analytics Workspace Resource ID')
param logAnalytics string

var policyName = 'SWX-Diag-Settings-KV'

resource keyVaultDiagPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyName
    description: 'Deploy diagnostic settings for Key Vaults to Log Analytics if not present'
    metadata: {
      category: 'Monitoring'
    }
    mode: 'All'
    parameters: {
      logAnalytics: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace'
          description: 'Resource ID of the Log Analytics Workspace'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.KeyVault/vaults'
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                $schema: 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    type: 'Microsoft.KeyVault/vaults/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters('resourceName'), '/Microsoft.Insights/SWXDiagnostics')]'
                    properties: {
                      workspaceId: '[parameters('logAnalytics')]'
                      logs: [
                        {
                          categoryGroup: 'audit'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
              }
              parameters: {
                resourceName: "[field('name')]"
                logAnalytics: logAnalytics
              }
            }
          }
        }
      }
    }
  }
}
