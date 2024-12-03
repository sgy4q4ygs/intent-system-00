param managedIdentityName string

var repoOwner = 'sgy4q4ygs'
var ref = 'refs/head/master'
var repos = {
  intentSystem00: 'intent-system-00'
  intentDetector: 'intent-detector'
  intentAccess: 'intent-access'
  intentView: 'intent-view'
}

var federatedIdentityCredentials = [
  {
    name: '${repos.intentSystem00}-fedcred'
    subject: 'repo:${repoOwner}/${repos.intentSystem00}:ref:${ref}'
  }
  {
    name: '${repos.intentDetector}-fedcred'
    subject: 'repo:${repoOwner}/${repos.intentDetector}:ref:${ref}'
  }
  {
    name: '${repos.intentAccess}-fedcred'
    subject: 'repo:${repoOwner}/${repos.intentAccess}:ref:${ref}'
  }
  {
    name: '${repos.intentView}-fedcred'
    subject: 'repo:${repoOwner}/${repos.intentView}:ref:${ref}'
  }
]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: resourceGroup().location
}

@batchSize(1)
resource federatedIdentityCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = [
  for cred in federatedIdentityCredentials: {
    name: cred.name
    parent: managedIdentity
    properties: {
      audiences: [
        'api://AzureADTokenExchange'
      ]
      issuer: 'https://token.actions.githubusercontent.com'
      subject: cred.subject
    }
  }
]
