#!/usr/bin/env sh

PROJECT=intent-system-00

SUBSCRIPTION_NAME='Azure subscription 1'

RESOURCE_GROUP=$PROJECT-rg
LOCATION=centralus
IDENTITY_NAME=$PROJECT-id

az deployment sub create --name "$PROJECT-sub-deployment" \
    --template-file azure-rg.bicep \
    --location "$LOCATION" \
    --parameters resourceGroupName="$RESOURCE_GROUP" \
        location="$LOCATION"

az deployment group create --name "$IDENTITY_NAME-deployment" \
    --template-file azure-federated-id.bicep \
    --resource-group "$RESOURCE_GROUP" \
    --parameters managedIdentityName="$IDENTITY_NAME"

SUBSCRIPTION_ID=$(az account subscription list | \
    jq ".[] | select(.displayName == \"$SUBSCRIPTION_NAME\") | .subscriptionId" | \
    tr -d '"')

ROLE_ASSIGNEE_PRINCIPAL_ID=$(az identity show --name "$IDENTITY_NAME" \
    --resource-group "$RESOURCE_GROUP" | \
    jq '.principalId' | tr -d '"')

az role assignment create --role Contributor \
    --assignee-object-id "$ROLE_ASSIGNEE_PRINCIPAL_ID" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
