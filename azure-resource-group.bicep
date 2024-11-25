targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

resource mainRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
