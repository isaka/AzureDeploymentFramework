param Deployment string
param DeploymentURI string
param AVDAppGroupName string
param AVDAppGroupAppInfo object
param Global object
param Prefix string
param Environment string
param DeploymentID string
param Stage object
param OMSID string

resource AppGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-01-16-preview' existing = {
  name: AVDAppGroupName

  resource application 'applications@2024-01-16-preview' = {
    name: AVDAppGroupAppInfo.description
    properties: {
      description: AVDAppGroupAppInfo.description
      friendlyName: AVDAppGroupAppInfo.friendlyName
      filePath: AVDAppGroupAppInfo.filePath
      commandLineSetting: AVDAppGroupAppInfo.commandLineSetting
      commandLineArguments: AVDAppGroupAppInfo.commandLineArguments
      showInPortal: AVDAppGroupAppInfo.showInPortal
      iconPath: AVDAppGroupAppInfo.iconPath
      iconIndex: AVDAppGroupAppInfo.iconIndex
      applicationType: AVDAppGroupAppInfo.applicationType
    }
  }
}

// resource AppGroupDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'service'
//   scope: AppGroup::application
//   properties: {
//     workspaceId: OMSID
//     logs: [
//       {
//         enabled: true
//         category: 'Checkpoint'
//       }
//       {
//         enabled: true
//         category: 'Error'
//       }
//       {
//         enabled: true
//         category: 'Management'
//       }
//     ]
//   }
// }
