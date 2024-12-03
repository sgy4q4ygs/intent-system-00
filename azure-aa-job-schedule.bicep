param automationAccountName string
param runbooks array

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' existing = {
  name: automationAccountName
}

resource automationAccountsSchedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' existing = {
  name: 'schedule'
  parent: automationAccount
}

resource automationAccountsRunbooks 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' existing = [
  for runbook in runbooks: {
    name: runbook.name
    parent: automationAccount
  }
]

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
    dependsOn: [
      automationAccountsSchedule
      automationAccountsRunbooks
    ]
  }
]
