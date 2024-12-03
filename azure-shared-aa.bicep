param project string = 'intent-system-00'

param automationAccountName string = '${project}-aa'

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

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  name: 'followBudgetRunbook'
  parent: automationAccount
  location: location
  properties: {
    runbookType: 'PowerShell'
    logProgress: true
    logVerbose: true
    description: 'Automatically stops specific resources when a budget is exceeded.'
  }
}

resource runbookContent 'Microsoft.Automation/automationAccounts/runbooks/content@2023-01-01' = {
  name: '${automationAccountName}/${runbookName}/content'
  properties: {
    description: 'Script to stop resources'
    content: scriptContent
  }
  dependsOn: [
    runbook
  ]
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-01-01' = {
  name: guid(automationAccount.name, runbook.name, 'StopResourcesSchedule')
  properties: {
    runbook: {
      name: runbookName
    }
    schedule: {
      name: 'OnBudgetExceed'
    }
    parameters: {
      ResourceGroupName: resourceGroup().name
    }
  }
  dependsOn: [
    runbook
  ]
}
