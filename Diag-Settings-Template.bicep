targetScope = 'subscription'

param logAnalytics string

var policyDescription = 'This policy automatically deploys and enables diagnostic settings to send to a Log Analytics workspace'

var keyVaultPolicyName = 'SWX-Diagnostic-Settings-KeyVault'
var nsgPolicyName = 'SWX-Diagnostic-Settings-NSG'

resource keyVaultPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: keyVaultPolicyName
  properties: {
    displayName: keyVaultPolicyName
    description: policyDescription
    metadata: {
      category: 'Monitoring'
    }
    mode: 'all'
    parameters: {
      logAnalytics: {
        type: 'string'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace'
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
          name: 'SWXDiagnostics'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                targetScope: 'resource'
                param resourceName string
                param location string
                param logAnalytics string

                resource diag 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2021-05-01-preview' = {
                  name: '${resourceName}/Microsoft.Insights/SWXDiagnostics'
                  location: location
                  properties: {
                    workspaceId: logAnalytics
                    logs: [
                      {
                        categoryGroup: 'audit'
                        enabled: true
                      }
                    ]
                  }
                }
              }
              parameters: {
                resourceName: "[field('name')]"
                location: "[field('location')]"
                logAnalytics: logAnalytics
              }
            }
          }
        }
      }
    }
  }
}

resource nsgPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: nsgPolicyName
  properties: {
    displayName: nsgPolicyName
    description: policyDescription
    metadata: {
      category: 'Monitoring'
    }
    mode: 'all'
    parameters: {
      logAnalytics: {
        type: 'string'
        metadata: {
          displayName: 'Log Analytics workspace'
          description: 'Select the Log Analytics workspace'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Network/networkSecurityGroups'
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: 'SWXDiagnostics'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                targetScope: 'resource'
                param resourceName string
                param location string
                param logAnalytics string

                resource diag 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2021-05-01-preview' = {
                  name: '${resourceName}/Microsoft.Insights/SWXDiagnostics'
                  location: location
                  properties: {
                    workspaceId: logAnalytics
                    logs: [
                      {
                        category: 'NetworkSecurityGroupEvent'
                        enabled: true
                      }
                    ]
                  }
                }
              }
              parameters: {
                resourceName: "[field('name')]"
                location: "[field('location')]"
                logAnalytics: logAnalytics
              }
            }
          }
        }
      }
    }
  }
}
