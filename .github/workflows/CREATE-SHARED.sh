#!/usr/bin/env sh

PROJECT=intent-system-00

RESOURCE_GROUP=$PROJECT-rg
LOCATION=centralus
IDENTITY_NAME=$PROJECT-id

PLAYTHING_SQLADMIN_PASSWORD=Amg4380hg0vwu

IDENTITY_PRINCIPAL_ID=$(az identity show --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    | jq ".principalId" | tr -d '"')

az deployment group create --name "$PROJECT-shared-resources-deployment" \
    --resource-group "$RESOURCE_GROUP" \
    --template-file azure-rg-shared-resources.bicep \
    --parameters identityPrincipalId="$IDENTITY_PRINCIPAL_ID" \
        sqlAdminPassword="$PLAYTHING_SQLADMIN_PASSWORD"
