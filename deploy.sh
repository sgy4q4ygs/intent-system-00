#!/usr/bin/env sh

RESOURCE_GROUP=intent-system-00-rg
IDENTITY_NAME=intent-system-00-identity
EXPERIMENT_SQLADMIN_PASSWORD=Amg4380hg0vwu

az deployment sub create --name intent-system-00-sub-deployment \
    --location centralus \
    --template-file azure-resource-group.bicep \
    --parameters resourceGroupName="$RESOURCE_GROUP" \
        resourceGroupLocation=centralus

az identity create --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP"

IDENTITY_PRINCIPAL_ID=$(az identity show --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    | jq ".principalId" | tr -d '"')

az deployment group create \
    --name intent-system-00-deployment \
    --resource-group "$RESOURCE_GROUP" \
    --template-file azure-infrastructure.bicep \
    --parameters identityPrincipalId="$IDENTITY_PRINCIPAL_ID" \
        sqlAdminPassword="$EXPERIMENT_SQLADMIN_PASSWORD"
