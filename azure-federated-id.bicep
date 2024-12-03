param managedIdentityName string

param repos array = [
  {
    name: 'intent-system-00'
    ref: 'refs/heads/master'
    owner: 'sgy4q4ygs'
  }
  {
    name: 'intent-detector'
    ref: 'refs/heads/master'
    owner: 'sgy4q4ygs'
  }
  {
    name: 'intent-access'
    ref: 'refs/heads/master'
    owner: 'sgy4q4ygs'
  }
  {
    name: 'intent-view'
    ref: 'refs/heads/master'
    owner: 'sgy4q4ygs'
  }
]

var federatedIdentityCredentials = [
  for repo in repos: {
    name: '${repo.name}-fedcred'
    subject: 'repo:${repo.owner}/${repo.name}:ref:${repo.ref}'
  }
]

var location = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
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
