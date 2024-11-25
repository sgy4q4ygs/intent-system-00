#!/usr/bin/env sh

PROJECT=intent-system-00

RESOURCE_GROUP=$PROJECT-rg
LOCATION=centralus
IDENTITY_NAME=$PROJECT-identity

PLAYTHING_SQLADMIN_PASSWORD=Amg4380hg0vwu

az deployment sub create --name $PROJECT-sub-deployment \
    --location "$LOCATION" \
    --template-file azure-rg-shared.bicep \
    --parameters resourceGroupName="$RESOURCE_GROUP" \
        resourceGroupLocation="$LOCATION"

az identity create --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP"

IDENTITY_PRINCIPAL_ID=$(az identity show --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    | jq ".principalId" | tr -d '"')

az deployment group create \
    --name $PROJECT-deployment \
    --resource-group "$RESOURCE_GROUP" \
    --template-file azure-rg-shared-resources.bicep \
    --parameters identityPrincipalId="$IDENTITY_PRINCIPAL_ID" \
        sqlAdminPassword="$PLAYTHING_SQLADMIN_PASSWORD"
