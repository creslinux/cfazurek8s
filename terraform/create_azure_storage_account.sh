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

### Set Key in Env
# export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name cfazurek8s-aks-key-vault --query value -o tsv)
# echo $ARM_ACCESS_KEY

## Init Terraform
#./terraform init -backend-config='storage_account_name=poccfstorek8s' -backend-config='container_name=terrablob' -backend-config='key=cfazurek8s-management.tfstate'


## Add principle permissions to, min perms needed to instantiate AKS, collect principal output
#./createTerraformServicePrincipal.sh

## Export to Env, also add to vault
#export TF_VAR_client_id=<value of “appId” from principal output>
#export TF_VAR_client_secret=<value of “password” from principal output>

### Store in vault values in vault to be secure
## TF_VAR_client_id with the value of “appId” from principal output
## TF_VAR_client_secret with the value of “password” from principal output
#az keyvault secret set --vault-name  cfazurek8s-aks-key-vault  --name TF-VAR-client-id  --value <value of “appId” from principal output>
#az keyvault secret set --vault-name  cfazurek8s-aks-key-vault  --name TF-VAR-client-secret  --value <value of “password” from principal output>

### Setup AD for K8s
#export RBAC_AZURE_TENANT_ID='<Use Tenent id from principal output>'
#export RBAC_SERVER_APP_NAME='AKSAADServer2'
#export RBAC_SERVER_APP_URL='http://aksaadserver2'

### Create a random and set as password
## Linux
#export RBAC_SERVER_APP_SECRET=”$(cat /dev/urandom | tr -dc ‘a-zA-Z0–9’ | fold -w 32 | head -n 1)”
## OSX
#export RBAC_SERVER_APP_SECRET=”$(LC_CTYPE=C tr -dc A-Za-z0–9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 32 | xargs)”


### Create Active Directory for App -- Collect RBAC_SERVER_APP_* vars
#./create-azure-ad-server-app.sh

### Inside portal grant admin permision for the app
# Grant permission button for this server app (Active Directory → App registrations (preview) → All applications → AKSAADServer2) .
# Click on AKSAADServer2 application → Api permissions → Grant admin consent for.. Button

### Copy RBAC Permissions INTO file create-azure-ad-client-app.sh
#export RBAC_SERVER_APP_ID='<OUTPUT FROM CREATE AZURE AD SCRIPT>'
#export RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID='<OUTPUT FROM CREATE AZURE AD SCRIPT>'
#export RBAC_SERVER_APP_SECRET='<OUTPUT FROM CREATE AZURE AD SCRIPT>'

### Setup the client, keep the output ENV vars,set to env, also set into Vault
# source create-azure-ad-client-app.sh


###  to the cfazurek8s vault to preserve
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-server-app-id  --value <Value from create-azure-ad-client-app.sh>
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-server-app-secret --value <Value from create-azure-ad-client-app.sh>
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-client-app-id --value <Value from create-azure-ad-client-app.sh>
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-tenant-id --value <Value from create-azure-ad-client-app.sh>


### Deploy AKS via terraform
#export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name cfazurek8s-aks-key-vault --query value -o tsv)
#source export_tf_vars

## Create tf plan, write the file rancher-management-plan into .
#./terraform plan -out rancher-management-plan
## name the cluster
# cf_cluster1
## Enter resource group created earlier
# storage-account-rg

## Create Infrastructure from Code -- apply the plan
#./terraform apply rancher-management-plan


#
#export TF_VAR_client_id=14d0acc8-65d5-481b-966f-77096661c92b
#export RBAC_AZURE_TENANT_ID=e586b0db-7fda-4632-811d-d4591beb7ffd
#export TF_VAR_client_secret='6d7094b8-bd1d-4434-99fa-d77c1f5fdb89'
#export RBAC_SERVER_APP_NAME='AKSAADServer2'
#export RBAC_SERVER_APP_URL='http://aksaadserver2'
#export RBAC_SERVER_APP_SECRET='?(Ax$TP@)QL_tx&SOZ#h^^M!vsb*=XAc'
#export RBAC_SERVER_APP_ID=8b35094a-b9b5-42b6-a52a-bd29fc0475b9
#export RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID=37c9c52d-3328-47bf-bfa5-cc4dfb9270b8
#export RBAC_SERVER_APP_SECRET=SltMr4y06X9APW70AP^eMAEu_8K%AiXQ
#export TF_VAR_rbac_server_app_id=8b35094a-b9b5-42b6-a52a-bd29fc0475b9
#export TF_VAR_rbac_server_app_secret=SltMr4y06X9APW70AP^eMAEu_8K%AiXQ
#export TF_VAR_rbac_client_app_id=60a73ce0-eb65-47ec-8bab-32bed1bc5f72
#export TF_VAR_tenant_id=f300a60a-7646-46fd-a93e-1bd04da1c89b
#
#az keyvault secret set --vault-name  cfazurek8s-aks-key-vault  --name TF-VAR-client-id  --value 14d0acc8-65d5-481b-966f-77096661c92b
#az keyvault secret set --vault-name  cfazurek8s-aks-key-vault  --name TF-VAR-client-secret  --value 6d7094b8-bd1d-4434-99fa-d77c1f5fdb89
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-server-app-id  --value 8b35094a-b9b5-42b6-a52a-bd29fc0475b9
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-server-app-secret --value SltMr4y06X9APW70AP^eMAEu_8K%AiXQ
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-rbac-client-app-id --value 60a73ce0-eb65-47ec-8bab-32bed1bc5f72
#az keyvault secret set --vault-name cfazurek8s-aks-key-vault --name TF-VAR-tenant-id --value f300a60a-7646-46fd-a93e-1bd04da1c89b


## output of create plan
creslins-MacBook-Pro:terraform creslin$ ./terraform plan -out cfk8-management-plan
Acquiring state lock. This may take a few moments...
var.aks_name
  Name of the AKS cluster.

  Enter a value: cfk8scluster1

var.resource_group_name
  Name of the resource group already created.

  Enter a value: storage-account-rg

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.azurerm_resource_group.rg: Refreshing state...
azurerm_virtual_network.test: Refreshing state... [id=/subscriptions/747fcd2b-0071-4719-8c04-e80af06d1a92/resourceGroups/storage-account-rg/providers/Microsoft.Network/virtualNetworks/aksVirtualNetwork]
data.azurerm_subnet.kubesubnet: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_kubernetes_cluster.k8s will be created
  + resource "azurerm_kubernetes_cluster" "k8s" {
      + dns_prefix            = "aks"
      + fqdn                  = (known after apply)
      + id                    = (known after apply)
      + kube_admin_config     = (known after apply)
      + kube_admin_config_raw = (sensitive value)
      + kube_config           = (known after apply)
      + kube_config_raw       = (sensitive value)
      + kubernetes_version    = "1.12.5"
      + location              = "westeurope"
      + name                  = "cfk8scluster1"
      + node_resource_group   = (known after apply)
      + resource_group_name   = "storage-account-rg"
      + tags                  = {
          + "source" = "terraform"
        }

      + addon_profile {

          + http_application_routing {
              + enabled                            = false
              + http_application_routing_zone_name = (known after apply)
            }
        }

      + agent_pool_profile {
          + count           = 3
          + dns_prefix      = (known after apply)
          + fqdn            = (known after apply)
          + max_pods        = (known after apply)
          + name            = "agentpool"
          + os_disk_size_gb = 40
          + os_type         = "Linux"
          + type            = "AvailabilitySet"
          + vm_size         = "Standard_DS2_v2"
          + vnet_subnet_id  = "/subscriptions/747fcd2b-0071-4719-8c04-e80af06d1a92/resourceGroups/storage-account-rg/providers/Microsoft.Network/virtualNetworks/aksVirtualNetwork/subnets/kubesubnet"
        }

      + linux_profile {
          + admin_username = "vmuser1"

          + ssh_key {
              + key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHv3jjwzcvvYVctFZiDK0ZiLHV/vHjm66IPUuGjr22M+pPm+RFnnLSG0XsuAtv9YbaL8oB36qkneVDa8OHvS9w/fPnOtTDUFpNdeOkL5iq6TsZx90yEAhHeuQsi9Zg5gUv13tkZpclZ0CdQxKUuXGQFHa1MFRYNNq04z2rJDFyG4TMJoetN+KHfbWB0CIj1fuZDVJLH0kfGgZeDCprdauCkHbq+SXm6CLQRhewa0gFVtUC8GSBvZLgy3cK+wlffY6ty4LYbDoCKM7t3ILQ4ZlxMluPN+ItjQ+0Kz1TE6PQhcV92Elvb4NryQVU5u+nP+WYf1BcOXoIJDZf6NBKcd9x creslin@DannyMBP.local\n"
            }
        }

      + network_profile {
          + dns_service_ip     = "10.0.0.10"
          + docker_bridge_cidr = "172.17.0.1/16"
          + network_plugin     = "azure"
          + network_policy     = (known after apply)
          + pod_cidr           = (known after apply)
          + service_cidr       = "10.0.0.0/16"
        }

      + role_based_access_control {
          + enabled = true

          + azure_active_directory {
              + client_app_id     = "60a73ce0-eb65-47ec-8bab-32bed1bc5f72"
              + server_app_id     = "8b35094a-b9b5-42b6-a52a-bd29fc0475b9"
              + server_app_secret = (sensitive value)
              + tenant_id         = "f300a60a-7646-46fd-a93e-1bd04da1c89b"
            }
        }

      + service_principal {
          + client_id     = "14d0acc8-65d5-481b-966f-77096661c92b"
          + client_secret = (sensitive value)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: cfk8-management-plan

To perform exactly these actions, run the following command to apply:
    terraform apply "cfk8-management-plan"

