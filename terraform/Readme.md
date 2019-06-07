### Build Guide / PoC
##### Multi-K8s on Azure, IaC via Terraform, Vault Secrets & AD. 

Key Features:
* Repeatable Infratructue-as-Code path-to-live K8s clusters
* Terraform definitions 
* Least Privilege Terraform AD role 
* Security secrets / tokens stored within Vault

Purpose: 

Provide consistent environments across project life cycle for developmet, test, stage and production.

**Contents:** 
* Provision Storage Account,Resource Group, and Blob for Terraform
* Provision Vault and Vault Resource Group

**Pre-Requisites:** 
 * az azure cmdline tool
 * terraform cmdline binany
 * git this repo
 * azure account

###### 1 Create Storage Account for Terraform and Storage Resource Group
Login to azure, set account to use:
```
az account list --output table
az account set -s <your-azure-account-name>
az login
```

Edit Variables in `create_azure_storage_account.sh`

```
LOCATION='westeurope'
RESOURCE_GROUP_NAME='storage-account-rg'
STORAGE_ACCOUNT_NAME='poccfstorek8s'
CONTAINER_NAME='terrablob'
```

Provision storage account, rg , and blob:

`source create-azure-storage-account.sh`

Check in Azure portal Account / RG / Blob are created
* Azure > Storage Accounts > 'poccfstorek8s'
* Azure > Resource Groups > 'storage_account_rg'
* Azure > Resource groups > storage-account-rg > poccfstorek8s >  Blobs > 'terrablob'

###### 2 Create Vault and Vault Resource Group
