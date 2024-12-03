param automationAccountName string
param runbooks array

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' existing = {
  name: automationAccountName
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = [
  for runbook in runbooks: {
    parent: automationAccount
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
