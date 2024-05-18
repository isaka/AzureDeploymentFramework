param Deployment string
param DeploymentURI string
param AVDHostPoolInfo object
param Global object
param Prefix string
param Environment string
param DeploymentID string
param Stage object
param OMSID string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-01-16-preview' = {
  name: '${Deployment}-avdhp${AVDHostPoolInfo.Name}'
  location: AVDHostPoolInfo.?location ?? resourceGroup().location
  properties: {
    description: AVDHostPoolInfo.Description
    managedPrivateUDP: 'Default'
    directUDP: 'Default'
    publicUDP: 'Default'
    relayUDP: 'Default'
    managementType: 'Standard'
    hostPoolType: 'Pooled'
    customRdpProperty: 'targetisaadjoined:i:1;drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:1;usbdevicestoredirect:s:;enablecredsspsupport:i:0;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;camerastoredirect:s:;redirectlocation:i:1;keyboardhook:i:1;'
    maxSessionLimit: 10
    loadBalancerType: 'BreadthFirst'
    validationEnvironment: false
    // vmTemplate: '{"domain":"","galleryImageOffer":"windows-11","galleryImagePublisher":"microsoftwindowsdesktop","galleryImageSKU":"win11-23h2-avd","imageType":"Gallery","customImageId":null,"namePrefix":"VDTEast2","osDiskType":"StandardSSD_LRS","vmSize":{"id":"Standard_B2s","cores":2,"ram":4,"rdmaEnabled":false,"supportsMemoryPreservingMaintenance":true},"galleryItemId":"microsoftwindowsdesktop.windows-11win11-23h2-avd","hibernate":false,"diskSizeGB":128,"securityType":"TrustedLaunch","secureBoot":true,"vTPM":true,"vmInfrastructureType":"Cloud","virtualProcessorCount":null,"memoryGB":null,"maximumMemoryGB":null,"minimumMemoryGB":null,"dynamicMemoryConfig":false}'
    preferredAppGroupType: 'Desktop'
    startVMOnConnect: false
    agentUpdate: {
      maintenanceWindowTimeZone: Global.schedulerTimeZone
      type: 'Scheduled'
      maintenanceWindows: [
        {
          dayOfWeek: 'Sunday'
          hour: 3
        }
      ]
    }
  }
}

resource HostPoolDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'service'
  scope: hostPool
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
        category: 'Connection'
      }
      {
        enabled: true
        category: 'HostRegistration'
      }
      {
        enabled: true
        category: 'AgentHealthStatus'
      }
      {
        enabled: true
        category: 'NetworkData'
      }
      {
        enabled: true
        category: 'ConnectionGraphicsData'
      }
      {
        enabled: true
        category: 'SessionHostManagement'
      }
      {
        enabled: true
        category: 'AutoscaleEvaluationPooled'
      }
    ]
  }
}

