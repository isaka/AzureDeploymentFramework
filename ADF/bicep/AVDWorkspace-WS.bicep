param Deployment string
param DeploymentURI string
param AVDWorkspaceInfo object
param Global object
param Prefix string
param Environment string
param DeploymentID string
param Stage object
param OMSID string

var AVDAppGroupName = AVDWorkspaceInfo.?AppGroupName ?? []

resource AppGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-01-16-preview' existing = [for (ag, index) in AVDAppGroupName: {
  name: '${Deployment}-avdag${ag}'
}]

resource avdworkspace 'Microsoft.DesktopVirtualization/workspaces@2024-01-16-preview' = {
  name: '${Deployment}-avdws${AVDWorkspaceInfo.Name}'
  location: AVDWorkspaceInfo.?location ?? resourceGroup().location
  properties: {
    publicNetworkAccess: AVDWorkspaceInfo.publicNetworkAccess
    description: AVDWorkspaceInfo.description
    friendlyName: AVDWorkspaceInfo.friendlyName
    applicationGroupReferences: [for (ag, index) in AVDAppGroupName: AppGroup[index].id]
  }
}

resource SQLDBDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'service'
  scope: avdworkspace
  properties: {
    workspaceId: OMSID
    logs: [
      {
        enabled: true
        category: 'Checkpoint'
      }
      {
        enabled: true
        category: 'Error'
      }
      {
        enabled: true
        category: 'Management'
      }
      {
        enabled: true
        category: 'Feed'
      }
    ]
  }
}

output AVDAppGroupName array = AVDAppGroupName
