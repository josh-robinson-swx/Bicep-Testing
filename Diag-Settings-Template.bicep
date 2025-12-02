targetScope = 'subscription'

@description('Log Analytics Workspace Resource ID')
param logAnalytics string

var policyDescription = 'This policy automatically deploys and enables diagnostic settings to send to a Log Analytics workspace'

var keyVaultPolicyName = 'SWX-Diagnostic-Settings-KeyVault'
var nsgPolicyName = 'SWX-Diagnostic-Settings-NSG'
var saBlobPolicyName = 'SWX-Diagnostic-Settings-StorageAccounts-Blob'
var saFilePolicyName = 'SWX-Diagnostic-Settings-StorageAccounts-File'
var saQueuePolicyName = 'SWX-Diagnostic-Settings-StorageAccounts-Queue'
var saTablePolicyName = 'SWX-Diagnostic-Settings-StorageAccounts-Table'

resource keyVaultPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: keyVaultPolicyName
  properties: {
    displayName: keyVaultPolicyName
    description: policyDescription
    metadata: { category: 'Monitoring' }
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
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: { type: 'string' }
                  logAnalytics: { type: 'string' }
                  location: { type: 'string' }
                }
                resources: [
                  {
                    type: 'Microsoft.KeyVault/vaults/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/SWXDiagnostics\')]'
                    location: '[parameters(\'location\')]'
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
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
                logAnalytics: { value: "[parameters('logAnalytics')]" }
                location: { value: "[field('location')]" }
                resourceName: { value: "[field('name')]" }
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
    metadata: { category: 'Monitoring' }
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
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: { type: 'string' }
                  logAnalytics: { type: 'string' }
                  location: { type: 'string' }
                }
                resources: [
                  {
                    type: 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/SWXDiagnostics\')]'
                    location: '[parameters(\'location\')]'
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
                      logs: [
                        {
                          category: 'NetworkSecurityGroupEvent'
                          enabled: true
                        }
                      ]
                    }
                  }
                ]
              }
              parameters: {
                logAnalytics: { value: "[parameters('logAnalytics')]" }
                location: { value: "[field('location')]" }
                resourceName: { value: "[field('name')]" }
              }
            }
          }
        }
      }
    }
  }
}

var storagePolicies = [
  {
    name: saBlobPolicyName
    serviceType: 'blobServices'
  }
  {
    name: saFilePolicyName
    serviceType: 'fileServices'
  }
  {
    name: saQueuePolicyName
    serviceType: 'queueServices'
  }
  {
    name: saTablePolicyName
    serviceType: 'tableServices'
  }
]

resource storagePoliciesDeploy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for s in storagePolicies: {
  name: s.name
  properties: {
    displayName: s.name
    description: policyDescription
    metadata: { category: 'Monitoring' }
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
        equals: 'Microsoft.Storage/storageAccounts'
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Storage/storageAccounts/${s.serviceType}/providers/diagnosticSettings'
          name: 'SWXDiagnostics'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: { type: 'string' }
                  logAnalytics: { type: 'string' }
                  location: { type: 'string' }
                }
                resources: [
                  {
                    type: 'Microsoft.Storage/storageAccounts/${s.serviceType}/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/SWXDiagnostics\')]'
                    location: '[parameters(\'location\')]'
                    properties: {
                      workspaceId: '[parameters(\'logAnalytics\')]'
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
                logAnalytics: { value: "[parameters('logAnalytics')]" }
                location: { value: "[field('location')]" }
                resourceName: { value: "[field('name')]" }
              }
            }
          }
        }
      }
    }
  }
}]
