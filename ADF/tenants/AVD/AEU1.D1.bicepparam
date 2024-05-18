using '../../bicep/00-ALL-SUB.bicep'

param Global = union(
  loadJsonContent('Global-${Prefix}.json'),
  loadJsonContent('Global-Global.json'),
  loadJsonContent('Global-Config.json')
)

param Prefix = 'AEU1'

param Environment = 'D'

param DeploymentID = '1'

param Stage = {
  RG: 1
  RBAC: 1
  PIM: 0
  UAI: 1
  SP: 0
  KV: 0
  DDOSPlan: 0
  OMS: 1
  OMSSolutions: 0
  OMSDataSources: 0
  OMSUpdateWeekly: 0
  OMSUpdateMonthly: 0
  OMSUpates: 0
  SA: 1
  ACR: 0
  CDN: 0
  StorageSync: 0
  RSV: 0
  NSG: 1
  NetworkWatcher: 0
  FlowLogs: 1
  VNet: 1
  VNetDDOS: 0
  VNetPeering: 1
  DNSPublicZone: 0
  DNSPrivateZone: 0
  LinkPrivateDns: 0
  PrivateLink: 0
  BastionHost: 0
  CloudShellRelay: 0
  RT: 0
  FW: 0
  VNGW: 0
  NATGW: 1
  ERGW: 0
  LB: 0
  TM: 0
  WAFPOLICY: 0
  WAF: 0
  FRONTDOORPOLICY: 0
  FRONTDOOR: 0
  SetExternalDNS: 0
  SetInternalDNS: 0
  APPCONFIG: 0
  REDIS: 0
  APIM: 0
  SQLMI: 0
  CosmosDB: 0
  DASHBOARD: 0
  ServerFarm: 0
  WebSite: 0
  WebSiteContainer: 0
  ManagedEnv: 0
  ContainerApp: 0
  MySQLDB: 0
  Function: 0
  SB: 0
  LT: 0
  AzureSYN: 0
  AVDHostPool: 1
  AVDHostAppGroup: 1
  AVDHostWorkSpace: 1
  // below require secrets from KV
  VMSS: 0
  ACI: 0
  AKS: 0
  AzureSQL: 0
  SFM: 0
  SFMNP: 0
  AVD: 1
  // VM templates
  ADPrimary: 0
  ADSecondary: 0
  InitialDOP: 0
  VMApp: 1
  VMSQL: 0
  VMFILE: 0
}

param Extensions = {
  MonitoringAgent: 0
  IaaSDiagnostics: 1
  DependencyAgent: 1
  AzureMonitorAgent: 1
  GuestHealthAgent: 0
  VMInsights: 1
  AdminCenter: 0
  BackupWindowsWorkloadSQL: 0
  DSC: 1
  GuestConfig: 0
  Scripts: 0
  MSI: 0
  CertMgmt: 0
  DomainJoin: 0
  AADLogin: 1
  Antimalware: 1
  VMSSAzureADEnabled: 0
  SqlIaasExtension: 0
  AzureDefender: 0
  GuestAttestation: 1
}

param DeploymentInfo = {
  uaiInfo: [
    // {
    //   name: 'KeyVaultSecretsGet'
    //   RBAC: [
    //     {
    //       Name: 'Key Vault Secrets User'
    //     }
    //   ]
    // }
    {
      name: 'Automation'
      RBAC: [
        {
          Name: 'Key Vault Secrets User'
        }
        {
          Name: 'Storage Account Contributor'
        }
        {
          Name: 'Storage Queue Data Contributor'
        }
        {
          Name: 'Storage Blob Data Owner'
        }
      ]
    }
    {
      name: 'StorageAccountFileContributor'
      RBAC: [
        {
          Name: 'Desktop Virtualization Reader'
        }
        {
          Name: 'Storage File Data SMB Share Contributor'
          RG: 'G1'
          Tenant: 'HUB'
          OrgName: 'PE'
          Prefix: 'AEU1'
        }
        {
          Name: 'Storage Blob Data Contributor'
          RG: 'G1'
          Tenant: 'HUB'
          OrgName: 'PE'
          Prefix: 'AEU1'
        }
        {
          Name: 'Storage Queue Data Contributor'
          RG: 'G1'
          Tenant: 'HUB'
          OrgName: 'PE'
          Prefix: 'AEU1'
        }
      ]
    }
  ]
  PIMInfo: []
  rolesInfo: [
    {
      Name: 'brwilkinson'
      RBAC: [
        {
          Name: 'Virtual Machine User Login'
        }
      ]
    }
    {
      Name: 'BenWilkinson-ADM'
      RBAC: [
        {
          Name: 'Reader'
        }
        {
          Name: 'Contributor'
        }
        {
          Name: 'Virtual Machine Administrator Login'
        }
        {
          Name: 'Virtual Machine User Login'
        }
      ]
    }
  ]
  SPInfo: []
  SubnetInfo: [
    {
      name: 'snFE01'
      prefix: '0/26'
      NSG: 1
      Route: 0
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
      NGW: 1
    }
  ]
  NatGWInfo: [
    {
      Name: 'NAT01'
      PIPCount: 1
    }
  ]
  OMSSolutions: [
    'Security'
    'ChangeTracking'
    'AzureActivity'
    'AlertManagement'
    'SecurityInsights'
    // 'KeyVaultAnalytics'
    'NetworkMonitoring'
    'InfrastructureInsights'
    'VMInsights'
    'WindowsDefenderATP'
    'BehaviorAnalyticsInsights'
  ]
  KVInfo: [
    {
      Name: 'VLT01'
      skuName: 'standard'
      softDelete: true
      PurgeProtection: true
      RbacAuthorization: true
      allNetworks: 1
      _PrivateLinkInfo: [
        {
          Subnet: 'snMT02'
          groupID: 'vault'
        }
      ]
    }
  ]
  saInfo: [
    {
      name: 'diag'
      skuName: 'Standard_LRS'
      allNetworks: 0
      logging: {
        r: 0
        w: 0
        d: 1
      }
      blobVersioning: 1
      changeFeed: 1
      softDeletePolicy: {
        enabled: 1
        days: 7
      }
    }
  ]
  AVDHostPoolInfo: [
    {
      Name: 'CLIENT01'
      Description: 'Test pool CLIENT'
    }
  ]
  AVDAppGroupInfo: [
    {
      Name: 'Desktop01'
      Description: 'Test pool CLIENT'
      Kind: 'Desktop'
      HostPoolName: 'CLIENT01'
      description: 'Desktop Application Group'
      friendlyName: 'Default Desktop'
      DesktopVirtualizationUser: [
        // 'brwilkinson'
      ]
    }
    {
      Name: 'WebApp01'
      Description: 'WebApp'
      Kind: 'RemoteApp'
      HostPoolName: 'CLIENT01'
      description: 'WebApp'
      friendlyName: 'WebAppEdge'
      DesktopVirtualizationUser: [
        'brwilkinson'
      ]
      Applications: [
        {
          description: 'WebApp'
          friendlyName: 'Web App - EastUS'
          filePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
          commandLineSetting: 'Require'
          commandLineArguments: 'https://portal.azure.com'
          showInPortal: true
          iconPath: 'C:\\source\\avd\\favicon.ico'
          iconIndex: 0
          applicationType: 'Inbuilt'
        }
      ]
    }
  ]
  AVDWorkspaceInfo: [
    {
      Name: 'CLIENT01'
      AppGroupName: [
        'Desktop01'
        'WebApp01'
      ]
      Description: 'WebApp Workspace'
      description: 'WebApp Workspace'
      friendlyName: 'WebApp Workspace'
      publicNetworkAccess: 'Enabled'
    }
  ]
  Appservers: {
    AppServers: [
      {
        Name: 'CLIENT01'
        Role: 'AVD'
        OSType: 'Win11AVD02'
        HotPatch: true
        intune: 1
        Zone: 1
        NICs: [
          {
            Subnet: 'snFE01'
            Primary: 1
          }
        ]
      }
      {
        Name: 'CLIENT02'
        Role: 'AVD'
        OSType: 'Win11AVD02'
        HotPatch: true
        intune: 1
        Zone: 3
        NICs: [
          {
            Subnet: 'snFE01'
            Primary: 1
          }
        ]
      }
    ]
  }
}
