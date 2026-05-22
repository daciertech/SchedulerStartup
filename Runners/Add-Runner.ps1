
param (
    [Parameter(Mandatory = $true, Position=0, HelpMessage = "The name of the resource group which will hold the runner:")]
    [string] $resourceGroupName,
    [Parameter(Mandatory = $true, Position=1, HelpMessage = "The name of your Dacier Scheduler instance:")]
    [string] $instanceName,
    [Parameter(Mandatory = $true, Position=2, HelpMessage = "The name for the new Runner container:")]
    [string] $runnerName,
    [Parameter(Mandatory = $true, Position=3, HelpMessage = "The path for the new Runner container:")]
    [string] $runnerPath)

$id = az identity show `
  --resource-group $resourceGroupName `
  --name 'IDDemoRunner' `
  --query id `
  --output tsv

$workspaceId = az monitor log-analytics workspace show `
  --resource-group $resourceGroupName `
  --workspace-name 'LADacierRunners' `
  --query customerId `
  --output tsv

$workspaceKey = az monitor log-analytics workspace get-shared-keys `
  --resource-group $resourceGroupName `
  --workspace-name 'LADacierRunners' `
  --query primarySharedKey `
  --output tsv

az container create `
  --resource-group $resourceGroupName `
  --name $runnerName.ToLowerInvariant() `
  --image ghcr.io/daciertech/scheduler-runner-service:latest `
  --assign-identity $id `
  --cpu 1 `
  --memory 1 `
  --log-analytics-workspace $workspaceId `
  --log-analytics-workspace-key $workspaceKey `
  --environment-variables `
      DACIER_TENANT_NAME=$instanceName `
      DACIER_SERVER_ADDRESS=http://hub.eastus.cloudautomation.com `
      DACIER_RUNNER_NAME=$runnerPath
