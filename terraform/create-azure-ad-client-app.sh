#!/bin/bash
set -e

# load environment variables
export RBAC_AZURE_TENANT_ID="f300a60a-7646-46fd-a93e-1bd04da1c89b"
export RBAC_CLIENT_APP_NAME="AKSAADClient3"
export RBAC_CLIENT_APP_URL="http://aksaadclient3"

# export RBAC_SERVER_APP_ID="COMPLETE_AFTER_SERVER_APP_CREATION"
# export RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID="COMPLETE_AFTER_SERVER_APP_CREATION"
# export RBAC_SERVER_APP_SECRET="COMPLETE_AFTER_SERVER_APP_CREATION"


export RBAC_SERVER_APP_ID=8b35094a-b9b5-42b6-a52a-bd29fc0475b9
export RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID=37c9c52d-3328-47bf-bfa5-cc4dfb9270b8
export RBAC_SERVER_APP_SECRET=SltMr4y06X9APW70AP^eMAEu_8K%AiXQ


# generate manifest for client application
cat > ./manifest-client.json << EOF
[
    {
      "resourceAppId": "${RBAC_SERVER_APP_ID}",
      "resourceAccess": [
        {
          "id": "${RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID}",
          "type": "Scope"
        }
      ]
    }
]
EOF

# create client application
az ad app create --display-name ${RBAC_CLIENT_APP_NAME} \
    --native-app \
    --reply-urls "${RBAC_CLIENT_APP_URL}" \
    --homepage "${RBAC_CLIENT_APP_URL}" \
    --required-resource-accesses @manifest-client.json

RBAC_CLIENT_APP_ID=$(az ad app list --display-name ${RBAC_CLIENT_APP_NAME} --query [].appId -o tsv)

# create service principal for the client application
az ad sp create --id ${RBAC_CLIENT_APP_ID}

# remove manifest-client.json
rm ./manifest-client.json

# grant permissions to server application
RBAC_CLIENT_APP_RESOURCES_API_IDS=$(az ad app permission list --id $RBAC_CLIENT_APP_ID --query [].resourceAppId --out tsv | xargs echo)
for RESOURCE_API_ID in $RBAC_CLIENT_APP_RESOURCES_API_IDS;
do
  az ad app permission grant --api $RESOURCE_API_ID --id $RBAC_CLIENT_APP_ID
done

# Output terraform variables
echo "
export TF_VAR_rbac_server_app_id="${RBAC_SERVER_APP_ID}"
export TF_VAR_rbac_server_app_secret="${RBAC_SERVER_APP_SECRET}"
export TF_VAR_rbac_client_app_id="${RBAC_CLIENT_APP_ID}"
export TF_VAR_tenant_id="${RBAC_AZURE_TENANT_ID}"
"

