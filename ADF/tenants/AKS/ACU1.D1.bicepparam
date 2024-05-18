using '../../bicep/00-ALL-SUB.bicep'

param Global = union(
  loadJsonContent('Global-${Prefix}.json'),
  loadJsonContent('Global-Global.json'),
  loadJsonContent('Global-Config.json')
)

param Prefix = 'ACU1'

param Environment = 'D'

param DeploymentID = '1'

param Stage = {
  RG: 1
  RBAC: 1
  PIM: 0
  UAI: 1
  SP: 1
  KV: 0
  OMS: 1
  OMSSolutions: 1
  OMSDataSources: 1
  OMSUpdateWeekly: 0
  OMSUpdateMonthly: 0
  OMSUpates: 1
  SA: 1
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
  WAFPOLICY: 1
  WAF: 0
  FRONTDOORPOLICY: 0
  FRONTDOOR: 0
  SetExternalDNS: 0
  SetInternalDNS: 0
  APPCONFIG: 0
  REDIS: 0
  APIM: 0
  ACR: 0
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
  VMSS: 0
  ACI: 0
  AKS: 1
  AzureSQL: 0
  SFM: 0
  SFMNP: 0
  ADPrimary: 0
  ADSecondary: 0
  InitialDOP: 0
  VMApp: 0
  VMAppLinux: 0
  VMSQL: 0
  VMFILE: 0
}

param Extensions = {
  MonitoringAgent: 1
  IaaSDiagnostics: 1
  DependencyAgent: 1
  AzureMonitorAgent: 1
  GuestHealthAgent: 1
  VMInsights: 1
  AdminCenter: 1
  BackupWindowsWorkloadSQL: 0
  DSC: 0
  GuestConfig: 1
  Scripts: 1
  MSI: 1
  CertMgmt: 0
  DomainJoin: 1
  AADLogin: 0
  WindowsOpenSSH: 0
  Antimalware: 1
  VMSSAzureADEnabled: 0
  SqlIaasExtension: 0
  AzureDefender: 0
  chefClient: 0
}

param DeploymentInfo = {
  uaiInfo: [
    {
      name: 'GlobalAcrPull'
      RBAC: [
        {
          Name: 'AcrPull'
          RG: 'G1'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
    {
      name: 'ML'
      RBAC: [
        {
          Name: 'AcrPull'
          RG: 'G1'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Reader'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
    {
      name: 'KeyVaultSecretsGet'
      RBAC: [
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
    {
      name: 'AKSCluster'
      RBAC: [
        {
          Name: 'Private DNS Zone Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Certificates Officer'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Network Contributor'
        }
        {
          Name: 'Managed Identity Operator'
        }
      ]
    }
    {
      name: 'Automation'
      RBAC: [
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
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
          Name: 'Storage File Data SMB Share Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Storage Blob Data Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Storage Queue Data Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
    {
      Name: 'CertificateRequest'
      RBAC: [
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Certificates Officer'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
  ]
  rolesInfo: [
    {
      Name: 'brwilkinson'
      RBAC: [
        {
          Name: 'Contributor'
        }
      ]
    }
  ]
  PIMInfo: []
  SPInfo: [
    {
      Name: 'ADO_{ADOProject}_{RGNAME}'
      RBAC: [
        {
          Name: 'Contributor'
        }
        {
          Name: 'DNS Zone Contributor'
          RG: 'G1'
          Prefix: 'ACU1'
          Tenant: 'HUB'
        }
        {
          Name: 'Reader and Data Access'
          RG: 'G1'
          Prefix: 'ACU1'
          Tenant: 'HUB'
        }
        {
          Name: 'Storage Account Contributor'
          RG: 'G1'
          Prefix: 'ACU1'
          Tenant: 'HUB'
        }
        {
          Name: 'Log Analytics Contributor'
          RG: 'G1'
          Prefix: 'ACU1'
          Tenant: 'HUB'
        }
        {
          Name: 'Desktop Virtualization Virtual Machine Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Key Vault Secrets User'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
        {
          Name: 'Network Contributor'
          RG: 'P0'
          Tenant: 'HUB'
          Prefix: 'ACU1'
        }
      ]
    }
  ]
  SubnetInfo: [
    {
      name: 'snMT03'
      prefix: '96/27'
      NSG: 1
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
      delegations: 'Microsoft.App/environments'
      NGW: 1
    }
    {
      name: 'AzureBastionSubnet'
      prefix: '192/26'
      NSG: 1
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
      NGW: 1
    }
    {
      name: 'waf01-subnet'
      NSGRuleName: 'SNWAF01'
      AddDeploymentPrefix: 1
      prefix: '0/24'
      NSG: 1
      Route: 0
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
    }
    {
      name: 'snFE01'
      prefix: '0/23'
      NSG: 1
      Route: 0
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
      NGW: 1
    }
    {
      name: 'snMT01'
      prefix: '0/23'
      NSG: 1
      Route: 0
      FlowLogEnabled: 1
      FlowAnalyticsEnabled: 1
      NGW: 1
    }
    {
      name: 'snMT02'
      prefix: '0/23'
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
  BastionInfo: {
    name: 'HST01'
    enableTunneling: 1
    scaleUnits: 2
  }
  saInfo: [
    {
      name: 'diag'
      skuName: 'Standard_LRS'
      allNetworks: 1
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
      PrivateLinkInfo: [
        {
          Subnet: 'snFE01'
          groupID: 'blob'
        }
        {
          Subnet: 'snFE01'
          groupID: 'file'
        }
      ]
    }
  ]
  KVInfo: [
    {
      Name: 'App01'
      skuName: 'standard'
      softDelete: true
      PurgeProtection: true
      RbacAuthorization: true
      UserAssignedIdentity: {
        name: 'KeyVaultSecretsGetApp'
        permission: 'SecretsGetAndList'
      }
      allNetworks: 1
      privateLinkInfo: [
        {
          Subnet: 'snFE01'
          groupID: 'vault'
        }
      ]
      _rolesInfo: [
        {
          Name: 'BenWilkinson'
          RBAC: [
            {
              Name: 'Key Vault Administrator'
            }
          ]
        }
      ]
    }
  ]
  OMSSolutions: [
    'AzureAutomation'
    'ChangeTracking'
    'AzureActivity'
    'DnsAnalytics'
    'AlertManagement'
    'NetworkMonitoring'
    'InfrastructureInsights'
    'VMInsights'
    'SecurityInsights'
    'WindowsDefenderATP'
    'KeyVaultAnalytics'
  ]
  WAFPolicyInfo: [
    {
      Name: 'AGIC01'
      State: 'Enabled'
      Mode: 'Prevention'
      ruleSetVersion: '3.2'
      enableBotRule: 1
      customRules: []
      exclusions: []
    }
  ]
  LoadTestInfo: [
    {
      Name: 'APIWebTest01'
      location: 'westus2'
    }
  ]
  WAFInfo: [
    {
      Name: 'AGIC01'
      WAFPolicyAttached: 1
      WAFPolicyName: 'AGIC01'
      WAFTier: 'WAF_v2'
      PrivateIP: '240'
      SSLCerts: [
        {
          name: 'AGIC01'
          zone: 'aginow.net'
          createCert: 1
          DnsNames: [
            '*.aginow.net'
          ]
        }
      ]
      _privateLinkInfo: [
        {
          Subnet: 'snMT01'
          groupID: 'frontendPublic'
        }
      ]
      backendAddressPools: [
        {
          name: 'AGIC01'
          BEIPs: []
        }
      ]
      pathRules: []
      probes: [
        {
          Name: 'probe01'
          Path: '/'
          Protocol: 'https'
          useBE: 1
        }
      ]
      frontEndPorts: [
        {
          Port: 80
        }
        {
          Port: 443
        }
      ]
      BackendHttp: [
        {
          Port: 443
          Protocol: 'https'
          CookieBasedAffinity: 'Disabled'
          RequestTimeout: 600
          probeName: 'probe01'
          hostnameFromBE: 1
        }
      ]
      Listeners: [
        {
          Port: 443
          BackendPort: 443
          Protocol: 'https'
          Cert: 'AGIC01'
          Domain: 'aginow.net'
          Hostname: 'AGIC01'
          HostnameExcludePrefix: 1
          Interface: 'Public'
        }
        {
          Port: 80
          Protocol: 'http'
          Domain: 'aginow.net'
          Hostname: 'AGIC01'
          HostnameExcludePrefix: 1
          Interface: 'Public'
          httpsRedirect: 1
        }
      ]
    }
  ]
  AKSInfo: [
    {
      Name: '01'
      Version: '1.28.3'
      skuTier: 'Free'
      podIdentity: 0
      privateCluster: 0
      AllowALLIPs: 1
      AgentPoolsSN: 'snMT01'
      WAFName: 'AGIC01'
      BrownFields: 1
      AppGateway: 0
      AutoScale: 1
      enableRBAC: 1
      enableOSM: 0
      enableIstio: 0
      enableIngressAppRouting: 1
      enableAppRoutingDNS: 0
      enableDefender: 0
      enablePolicy: 0
      enableaciConnector: 0
      aksAADAdminGroups: [
        'brwilkinson'
      ]
      AgentPools: [
        {
          name: 'system01'
          count: 1
          osDiskSizeGb: 0
          osType: 'Linux'
          osSKU: 'Mariner'
          maxPods: 110
          vmSize: 'Standard_D2ads_v5'
          mode: 'System'
          subnet: 'snMT01'
        }
      ]
    }
  ]
  MLWorkspaceInfo: [
    {
      Name: '03'
      UAI: 'ML'
      skuTier: 'Basic'
    }
  ]
}
