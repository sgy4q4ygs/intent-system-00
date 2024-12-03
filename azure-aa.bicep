param project string = 'intent-system-00'

param location string = resourceGroup().location

param automationAccountName string = '${project}-aa'
param runbooks array = [
  {
    name: 'follow-budget'
    type: 'PowerShell'
    description: 'Automatically stops specific resources when a budget is exceeded.'
    schedule: 'OnBudgetExceed'
  }
]

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

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = [
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

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = [
  for runbook in runbooks: {
    name: guid(automationAccount.name, runbook.name, 'StopResourcesSchedule')
    properties: {
      runbook: {
        name: runbook.name
      }
      schedule: {
        name: runbook.schedule
      }
      parameters: {
        ResourceGroupName: resourceGroup().name
      }
    }
  }
]
