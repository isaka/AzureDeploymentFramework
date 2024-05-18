param Deployment string
param DeploymentURI string
param AVDAppGroupInfo object
param Global object
param Prefix string
param Environment string
param DeploymentID string
param Stage object
param OMSID string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-01-16-preview' existing = {
  name: '${Deployment}-avdhp${AVDAppGroupInfo.HostPoolName}'
}

resource AppGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-01-16-preview' = {
  name: '${Deployment}-avdag${AVDAppGroupInfo.Name}'
  location: AVDAppGroupInfo.?location ?? resourceGroup().location
  kind: AVDAppGroupInfo.Kind
  properties: {
    hostPoolArmPath: hostPool.id
    description: AVDAppGroupInfo.description
    friendlyName: AVDAppGroupInfo.friendlyName
    applicationGroupType: AVDAppGroupInfo.Kind
  }
}

var users = AVDAppGroupInfo.?DesktopVirtualizationUser ?? []

module RBAC 'x.RBAC-ALL.bicep' = [for (user, index) in users: {
  name: take(replace('dp-rbac-role-${AVDAppGroupInfo.name}-VDI-User-${user}', '@', '_'), 64)
  params: {
    resourceId: AppGroup.id
    Global: Global
    roleInfo: {
      Name: user
      RBAC: [
        {
          Name: 'Desktop Virtualization User'
        }
      ]
    }
    Type: 'lookup'
    deployment: Deployment
  }
}]

resource AppGroupDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'service'
  scope: AppGroup
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
    ]
  }
}

var AVDAppGroupApplications = AVDAppGroupInfo.?Applications ?? []

module AppGroupApplications 'AVDAppGroup-AG-App.bicep' = [for (aga,index) in AVDAppGroupApplications : {
    name: '${Deployment}-avdag${AVDAppGroupInfo.Name}-${aga.description}'
    params: {
      Deployment: Deployment
      DeploymentURI: DeploymentURI
      AVDAppGroupAppInfo: aga
      AVDAppGroupName: '${Deployment}-avdag${AVDAppGroupInfo.Name}'
      Global: Global
      DeploymentID: DeploymentID
      Environment: Environment
      Prefix: Prefix
      Stage: Stage
      OMSID: OMSID
    }
}]


