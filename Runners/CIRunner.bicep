targetScope = 'subscription'

//
//  These parameters must be set in the ???.main.json file for the environment.
//
//
// These parameters are optional and can be set in the ???.main.json file for the environment, or will be auto-generated based on naming conventions if not provided.
//
param location string = 'EastUS2'
param containerCpuCoreCount string = '0.5'
param containerMemory string = '1.0Gi'
param containerGroups_dev_runner_01_workspaceKey string
param containerGroups_dev_runner_01_name string = 'dev-runner-01'


resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'RGDacierRunners'
  location: location
}

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' existing = {
   name: 'IDDacierRunner'
   scope: rg
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'LADacierRunners'
  scope: rg
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}





resource containerGroups_dev_runner_01_name_resource 'Microsoft.ContainerInstance/containerGroups@2025-09-01' = {
  name: containerGroups_dev_runner_01_name
  location: location
  scope: rg
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/f9d56a33-beed-4298-8d04-b0d9392cd2b3/resourcegroups/DevelopmentPermanent/providers/Microsoft.ManagedIdentity/userAssignedIdentities/IDRunnerDev': {}
    }
  }
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: containerGroups_dev_runner_01_name
        properties: {
          image: 'ghcr.io/daciertech/scheduler-runner-service:latest'
          ports: []
          environmentVariables: [
            {
              name: 'DACIER_TENANT_NAME'
              value: 'DacierDev'
            }
            {
              name: 'DACIER_SERVER_ADDRESS'
              value: 'http://hub.dev.daciertech.com'
            }
            {
              name: 'DACIER_RUNNER_NAME'
              value: '\\Prod\\Debug'
            }
          ]
          configMap: {
            keyValuePairs: {}
          }
          resources: {
            requests: {
              memoryInGB: json('1')
              cpu: json('1')
            }
          }
        }
      }
    ]
    initContainers: []
    restartPolicy: 'Always'
    osType: 'Linux'
    diagnostics: {
      logAnalytics: {
        workspaceId: '523f68cd-e49b-454d-bfaa-25fbcae5d9a6'
        logType: 'ContainerInstanceLogs'
        workspaceKey: containerGroups_dev_runner_01_workspaceKey
      }
    }
  }
}
