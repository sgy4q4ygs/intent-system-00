param automationAccountName string
param runbooks array

param location string = resourceGroup().location

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

resource automationAccountsSchedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  name: 'schedule'
  parent: automationAccount
  properties: {
    frequency: 'OneTime'
    startTime:
  }
}

resource automationAccountsRunbooks 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = [
  for runbook in runbooks: {
    name: runbook.name
    parent: automationAccount
    location: location
    properties: {
      runbookType: runbook.type
      description: runbook.description
      logProgress: true
      logVerbose: true
    }
  }
]
