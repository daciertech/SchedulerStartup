# Deploy a Runner in Azure

Deploying a Runner for the Dacier Scheduler is easy! A Runner is a Container with just a few simple configuration settings. You can deploy using Azure CLI commands or Bicep.

## Resource Group

In Azure resources are managed with "Resource Groups". You should know which Resource Group your are going to use for the Runner.

## Managed Account

The first step in deploying a Runner is to decide what account it is going to run under. We suggest using an Azure Managed Account. The account the Runner uses will control what jobs are able to do. You may want to have multiple Runners so that you can have multiple security environments.

If you don't already have a Managed Account that you want to use for the Runner, you can create one with the Azure GUI or with a command like:

```bash
az identity create \
  --name myManagedIdentity \
  --resource-group myResourceGroup \
  --location eastus
```

Adjust the names and locations to match your needs.

To assign that managed identity to a container you will need the identitiy's resource ID. You can retrieve that ID with a command like:

```bash
az identity show \
  --resource-group myResourceGroup \
  --name myIdentity \
  --query id \
  --output tsv
```

Once you have a Managed Identity you can deploy a Runner with a command like:

```bash
az container create \
  --resource-group myResourceGroup \
  --name my-container \
  --image ghcr.io/daciertech/scheduler-runner-service \
  --assign-identity "/subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<IDENTITY_NAME>" \
  --cpu 1 \
  --memory 1 \
  --environment-variables \
      DACIER_TENANT_NAME=NameYouPicked \
      DACIER_SERVER_ADDRESS=http://hub.eastus.cloudautomation.com \
      FEATURE_FLAG=true
```

>[!NOTE]
>These example commands use Bash syntax of a backslash to continue a command on the next line. PowerShell uses a backtick (`) to continue a command on the next line.