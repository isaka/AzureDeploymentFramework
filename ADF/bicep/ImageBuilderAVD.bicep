param Prefix string

@allowed([
  'I'
  'D'
  'U'
  'P'
  'S'
  'G'
  'A'
])
param Environment string = 'D'

@allowed([
  '0'
  '1'
  '2'
  '3'
  '4'
  '5'
  '6'
  '7'
  '8'
  '9'
  '10'
  '11'
  '12'
  '13'
  '14'
  '15'
  '16'
])
param DeploymentID string
#disable-next-line no-unused-params
param Stage object
#disable-next-line no-unused-params
param Extensions object
param Global object
param DeploymentInfo object
param now string = utcNow('yyyy-MM-dd_hh-mm')

param month string = utcNow('MM')
param year string = utcNow('yyyy')

// Use same PAT token for 3 month blocks, min PAT age is 6 months, max is 9 months
var SASEnd = dateTimeAdd('${year}-${padLeft((int(month) - (int(month) - 1) % 3), 2, '0')}-01', 'P9M')

// Roll the SAS token one per 3 months, min length of 6 months.
var DSCSAS = saaccountidglobalsource.listServiceSAS('2021-09-01', {
    canonicalizedResource: '/blob/${saaccountidglobalsource.name}/${last(split(Global._artifactsLocation, '/'))}'
    signedResource: 'c'
    signedProtocol: 'https'
    signedPermission: 'r'
    signedServices: 'b'
    signedExpiry: SASEnd
    keyToSign: 'key1'
  }).serviceSasToken

var GlobalRGJ = json(Global.GlobalRG)
var GlobalSAJ = json(Global.GlobalSA)
var HubRGJ = json(Global.hubRG)

var regionLookup = json(loadTextContent('./global/region.json'))
var primaryPrefix = regionLookup[Global.PrimaryLocation].prefix

var gh = {
  globalRGPrefix: contains(GlobalRGJ, 'Prefix') ? GlobalRGJ.Prefix : primaryPrefix
  globalRGOrgName: contains(GlobalRGJ, 'OrgName') ? GlobalRGJ.OrgName : Global.OrgName
  globalRGAppName: contains(GlobalRGJ, 'AppName') ? GlobalRGJ.AppName : Global.AppName
  globalRGName: contains(GlobalRGJ, 'name') ? GlobalRGJ.name : '${Environment}${DeploymentID}'

  globalSAPrefix: contains(GlobalSAJ, 'Prefix') ? GlobalSAJ.Prefix : primaryPrefix
  globalSAOrgName: contains(GlobalSAJ, 'OrgName') ? GlobalSAJ.OrgName : Global.OrgName
  globalSAAppName: contains(GlobalSAJ, 'AppName') ? GlobalSAJ.AppName : Global.AppName
  globalSARGName: contains(GlobalSAJ, 'RG') ? GlobalSAJ.RG : contains(GlobalRGJ, 'name') ? GlobalRGJ.name : '${Environment}${DeploymentID}'

  hubRGPrefix: HubRGJ.?Prefix ?? Prefix
  hubRGOrgName: HubRGJ.?OrgName ?? Global.OrgName
  hubRGAppName: HubRGJ.?AppName ?? Global.AppName
  hubRGRGName: HubRGJ.?name ?? HubRGJ.?name ?? '${Environment}${DeploymentID}'
}

var globalRGName = '${gh.globalRGPrefix}-${gh.globalRGOrgName}-${gh.globalRGAppName}-RG-${gh.globalRGName}'
var HubRGName = '${gh.hubRGPrefix}-${gh.hubRGOrgName}-${gh.hubRGAppName}-RG-${gh.hubRGRGName}'
var globalSAName = toLower('${gh.globalSAPrefix}${gh.globalSAOrgName}${gh.globalSAAppName}${gh.globalSARGName}sa${GlobalSAJ.name}')

resource saaccountidglobalsource 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  #disable-next-line BCP334
  name: globalSAName
  scope: resourceGroup(globalRGName)
}

var Deployment = '${Prefix}-${Global.OrgName}-${Global.Appname}-${Environment}${DeploymentID}'
var DeploymentURI = toLower('${Prefix}${Global.OrgName}${Global.Appname}${Environment}${DeploymentID}')
var OMSworkspaceName = replace('${Deployment}LogAnalytics', '-', '')
var OMSworkspaceID = resourceId('Microsoft.OperationalInsights/workspaces/', OMSworkspaceName)

// os config now shared across subscriptions
var computeGlobal = json(loadTextContent('./global/Global-ConfigVM.json'))
var OSType = computeGlobal.OSType

var ImageInfo = DeploymentInfo.?ImageInfo ?? []
var userAssignedIdentities = {
  Default: {
    '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', '${Deployment}-uaiImageBuilder')}': {}
  }
  None: {}
}
var image = [for (img, index) in ImageInfo: {
  match: ((Global.CN == '.') || contains(array(Global.CN), img.imageName))
  imageName: img.imageName
  imageBuildLocation: img.replicationRegions[0]
  stagingSubnetId: resourceId(img.stagingVNETRG, 'Microsoft.Network/virtualNetworks/subnets', img.stagingVNET, img.stagingSubnet)
}]

resource Gallery 'Microsoft.Compute/galleries@2021-07-01' existing = [for (img, index) in ImageInfo: {
  name: '${DeploymentURI}Gallery${img.GalleryName}'
}]

resource IMG 'Microsoft.Compute/galleries/images@2021-07-01' = [for (img, index) in ImageInfo: {
  #disable-next-line use-stable-resource-identifiers
  name: image[index].imageName
  parent: Gallery[index]
  location: resourceGroup().location
  properties: {
    description: img.imageName
    osType: OSType[img.OSType].OS
    osState: 'Generalized'
    hyperVGeneration: 'V2'
    features: [
      {
        name: 'SecurityType'
        value: 'TrustedLaunchSupported'
      }
      {
        name: 'IsAcceleratedNetworkSupported'
        value: 'True'
      }
      {
        name: 'DiskControllerTypes'
        value: 'SCSI, NVMe'
      }
      {
        name: 'IsHibernateSupported'
        value: 'True'
      }
    ]
    identifier: {
      publisher: '${DeploymentURI}_${image[index].imageName}'
      offer: OSType[img.OSType].imagereference.offer
      sku: OSType[img.OSType].imagereference.sku
    }
  }
}]

resource IMGTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2023-07-01' = [for (img, index) in ImageInfo: if (bool(image[index].match)) {
  name: image[index].imageName
  location: image[index].imageBuildLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentities.Default
  }
  tags: {
    AVD_IMAGE_TEMPLATE: 'AVD_IMAGE_TEMPLATE'
  }
  properties: {
    buildTimeoutInMinutes: 360 //img.deployTimeoutmin
    vmProfile: {
      vmSize: img.vmSize
      osDiskSizeGB: OSType[img.OSType].OSDiskGB
      vnetConfig: {
        subnetId: image[index].stagingSubnetId
      }
    }
    errorHandling: {
      onCustomizerError: 'abort'
      onValidationError: 'abort'
    }
    stagingResourceGroup: '${subscription().id}/resourceGroups/${img.stagingVNETRG}_${img.imageName}' //image[index].stagingResourceGroupId
    source: {
      type: 'PlatformImage'
      publisher: OSType[img.OSType].imagereference.publisher
      offer: OSType[img.OSType].imagereference.offer
      sku: OSType[img.OSType].imagereference.sku
      version: 'latest'
      planInfo: contains(OSType[img.OSType], 'plan') ? OSType[img.OSType].plan : null
    }
    customize: [
      {
        name: 'avdBuiltInScript_timeZoneRedirection'
        runAsSystem: true
        runElevated: true
        scriptUri: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2023-11-20/TimezoneRedirection.ps1'
        type: 'PowerShell'
      }
      {
        name: 'avdBuiltInScript_configureRdpShortpath'
        runAsSystem: true
        runElevated: true
        scriptUri: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2023-11-20/RDPShortpath.ps1'
        type: 'PowerShell'
      }
      {
        destination: 'C:\\AVDImage\\configureSessionTimeouts.ps1'
        name: 'avdBuiltInScript_configureSessionTimeouts'
        sourceUri: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2023-11-20/ConfigureSessionTimeoutsV2.ps1'
        type: 'File'
      }
      {
        inline: [
          'C:\\AVDImage\\configureSessionTimeouts.ps1 -MaxDisconnectionTime "120" -MaxIdleTime "180" -MaxConnectionTime "960" -RemoteAppLogoffTimeLimit "960"'
        ]
        name: 'avdBuiltInScript_configureSessionTimeouts-parameter'
        runAsSystem: true
        runElevated: true
        type: 'PowerShell'
      }
      {
        name: 'avdBuiltInScript_windowsUpdate'
        searchCriteria: ''
        type: 'WindowsUpdate'
        updateLimit: 0
      }
      {
        name: 'avdBuiltInScript_windowsUpdate-windowsRestart'
        restartCheckCommand: ''
        restartCommand: ''
        restartTimeout: ''
        type: 'WindowsRestart'
      }
      {
        destination: 'C:\\AVDImage\\windowsOptimization.ps1'
        name: 'avdBuiltInScript_windowsOptimization'
        sourceUri: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2023-11-20/WindowsOptimization.ps1'
        type: 'File'
      }
      {
        inline: [
          'C:\\AVDImage\\windowsOptimization.ps1 -Optimizations "Edge"'
        ]
        name: 'avdBuiltInScript_windowsOptimization-parameter'
        runAsSystem: true
        runElevated: true
        type: 'PowerShell'
      }
      {
        name: 'avdBuiltInScript_windowsOptimization-windowsUpdate'
        searchCriteria: ''
        type: 'WindowsUpdate'
        updateLimit: 0
      }
      {
        name: 'avdBuiltInScript_windowsOptimization-windowsRestart'
        restartCheckCommand: ''
        restartCommand: ''
        restartTimeout: ''
        type: 'WindowsRestart'
      }
      {
        name: 'avdBuiltInScript_adminSysPrep'
        runAsSystem: true
        runElevated: true
        scriptUri: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/CustomImageTemplateScripts/CustomImageTemplateScripts_2023-11-20/AdminSysPrep.ps1'
        type: 'PowerShell'
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: IMG[index].id
        runOutputName: image[index].imageName
        artifactTags: {
          source: 'azVmImageBuilder'
          baseosimg: OSType[img.OSType].imagereference.sku
        }
        storageAccountType: 'Standard_ZRS'
        replicationRegions: img.replicationRegions
      }
    ]
  }
}]

/*

resource SetImageBuild 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for (img, index) in ImageInfo: if (bool(image[index].match)) {
  name: 'SetImageBuild-${image[index].imageName}-${image[index].imageBuildLocation}'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentities.Default
  }
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '5.4'
    arguments: ' -ResourceGroupName ${resourceGroup().name} -ImageTemplateName ${image[index].imageName}-${image[index].imageBuildLocation}'
    scriptContent: loadTextContent('../bicep/loadTextContext/startImageBuildAsync.ps1')
    forceUpdateTag: now
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
    timeout: 'PT3M'
  }
  dependsOn: [
    IMGTemplate
  ]
}]

*/

// resource IMGVERSION 'Microsoft.Compute/galleries/images/versions@2021-07-01' = [for (img,index) in ImageInfo : if (img.PublishNow == 1) {
//   name: '${DeploymentURI}gallery${img.GalleryName}/${image[index].imageName}/0.0.1'
//   location: resourceGroup().location
//   properties: {
//     publishingProfile: {
//       replicaCount: 1
//       excludeFromLatest: false
//       targetRegions: [
//         {
//           name: resourceGroup().location
//           regionalReplicaCount: 1
//           storageAccountType: 'Standard_LRS'
//         }
//       ]
//     }
//     storageProfile: {
//       source: {
//         // uri: 
//         // id: IMG[index].id //resourceId('Microsoft.Compute/galleries/images', '${image[index].imageName}')
//         // /subscriptions/{subscriptionguid}/resourceGroups/ACU1-PE-AOA-RG-G1/providers/Microsoft.Compute/galleries/acu1brwaoag1gallery01/images/vmss2019webnetcore01
//       }
//     }
//   }
//   dependsOn: [
//     SetImageBuild
//   ]
// }]

output Identifier array = [for (img, index) in ImageInfo: IMG[index].id]
