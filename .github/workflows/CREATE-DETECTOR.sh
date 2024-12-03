#!/usr/bin/env sh

PROJECT=intent-system-00
RESOURCE_GROUP=$PROJECT-rg

FUNCTION_APP_NAME=intent-detector

STORAGE_ACCOUNT=$(echo $PROJECT | tr -d '-')storage

STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString \
    --output tsv)

az deployment group create \
    --name "$FUNCTION_APP_NAME-deployment" \
    --resource-group "$RESOURCE_GROUP" \
    --template-file azure-resources.bicep \
    --parameters \
        storageConnectionString="$STORAGE_CONNECTION_STRING"
