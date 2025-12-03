targetScope = 'subscription'

@description('Policy definition name')
param policyDefinitionName string = 'SWX-DiagnosticSettings-KeyVault'

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

var deployTemplate = json('''
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "logAnalyticsWorkspaceId": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Insights/diagnosticSettings",
      "apiVersion": "2021-05-01-preview",
      "name": "SWXDiagnostics",
      "properties": {
        "workspaceId": "[parameters('logAnalyticsWorkspaceId')]",
        "logs": [
          {
            "categoryGroup": "audit",
            "enabled": true
          },
          {
            "categoryGroup": "allLogs",
            "enabled": true
          }
        ],
        "metrics": [
          {
            "category": "AllMetrics",
            "enabled": false
          }
        ]
      }
    }
  ]
}
''')

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyDefinitionName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: policyDefinitionName
    description: 'This policy automatically deploys and enables diagnostic settings to send to a Log Analytics workspace'
    metadata: {
      category: 'Key Vault'
    }
    parameters: {
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace Resource ID'
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
          existenceCondition: {
            field: 'name'
            equals: 'SWXDiagnostics'
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/f526a384-b230-433c-b45c-95f59c4a2dec'
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: deployTemplate
              parameters: {
                logAnalyticsWorkspaceId: {
                  value: logAnalyticsWorkspaceId
                }
              }
            }
          }
        }
      }
    }
  }
}
