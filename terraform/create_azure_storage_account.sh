#!/bin/bash

# Creates Storage area to host Terraform script in Azure

  echo "Usage: ./create-azure-storage-account.sh"
  echo "NOTE: Use the following azure cli commands to check the right account and to login to az first:"
  echo "  az account list --output table                    => Check which Azure accounts you have."
  echo "  az account set -s \"<your-azure-account-name>\"     => Set the right azure account."
  echo "  az login                                          => Login to azure cli."

LOCATION='westeurope'
RESOURCE_GROUP_NAME='storage-account-rg'
STORAGE_ACCOUNT_NAME="poccfstorek8s"
CONTAINER_NAME='terrablob'

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --verbose --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"


### Create a vault to store the key within
#az group create --name key-vault-rg --location westeurope
#az keyvault create --name cfazurek8s-aks-key-vault --resource-group key-vault-rg --location westeurope
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name terraform-backend-key --value <ACCESS KEY FROM CREATE STORAGE SCRIPT>

### Check can Return the key from vault
#az keyvault secret show --name terraform-backend-key --vault-name cfazurek8s-aks-key-vault --query value -o tsv