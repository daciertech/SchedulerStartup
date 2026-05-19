
param (
    [Parameter(Mandatory = $true, Position=0, HelpMessage = "The name of the resource group which will hold the runner:")]
    [string] $resourceGroupName,
    [Parameter(Mandatory = $true, Position=1, HelpMessage = "The name of your Dacier Scheduler instance:")]
    [string] $instanceName,
    [Parameter(Mandatory = $true, Position=2, HelpMessage = "The name for the new Runner container:")]
    [string] $baseName,
    [Parameter(Mandatory = $true, Position=3, HelpMessage = "The name of the resource group which holds the Managed Identity:")]
    [string] $idResourceGroupName,
    [Parameter(Mandatory = $true, Position=4, HelpMessage = "The name of the Managed Identity:")]
    [string] $idName)

$id = az identity show `
  --resource-group $idResourceGroupName `
  --name $idName `
  --query id `
  --output tsv

az container create `
  --resource-group $resourceGroupName `
  --name $baseName.ToLowerInvariant() `
  --image ghcr.io/daciertech/scheduler-runner-service:latest `
  --assign-identity $id `
  --cpu 1 `
  --memory 1 `
  --environment-variables `
      DACIER_TENANT_NAME=$instanceName `
      DACIER_SERVER_ADDRESS=http://hub.dev.daciertech.com `
      DACIER_RUNNER_NAME='\Prod\Debug'
