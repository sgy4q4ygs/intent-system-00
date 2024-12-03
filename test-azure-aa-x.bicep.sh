#!/usr/bin/env sh

PROJECT_NAME=intent-system-00
DEPLOYMENT_NAME=aa
RESOURCE_GROUP_NAME=$PROJECT_NAME-rg

cat <<- EOL
az deployment group create --name "$PROJECT_NAME-$DEPLOYMENT_NAME-deployment" \

EOL
az deployment group create --name "$PROJECT_NAME-$DEPLOYMENT_NAME-deployment" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --template-file "azure-$DEPLOYMENT_NAME.bicep" \
  --parameters automationAccountName="$PROJECT_NAME-$DEPLOYMENT_NAME" \
    runbooks=@"runbooks.json"

for runbook_name in $(jq -r '.[].name' "runbooks.json"); do
cat <<- EOL
  az automation runbook replace-content \

EOL
  az automation runbook replace-content \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --automation-account-name "$PROJECT_NAME-$DEPLOYMENT_NAME" \
    --name "$runbook_name" \
    --content "$(cat "$runbook_name.ps1")"
done

for runbook_name in $(jq -r '.[].name' "runbooks.json"); do
cat <<- EOL
  az automation runbook publish \

EOL
  az automation runbook publish \
    --automation-account-name "$PROJECT_NAME-$DEPLOYMENT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$runbook_name"
done

cat <<- EOL
az deployment group create --name "$PROJECT_NAME-$DEPLOYMENT_NAME-job-schedule-deployment" \

EOL
az deployment group create --name "$PROJECT_NAME-$DEPLOYMENT_NAME-job-schedule-deployment" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --template-file "azure-$DEPLOYMENT_NAME-job-schedule.bicep" \
  --parameters automationAccountName="$PROJECT_NAME-$DEPLOYMENT_NAME" \
    runbooks=@"runbooks.json"
