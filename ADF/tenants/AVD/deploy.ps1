param (
    [string]$App = 'AVD'
)
$Base = $PSScriptRoot
Import-Module -Name "$Base/../../release-az/azSet.psm1" -Force
Import-Module -Name "$Base/../../release-az/ADOHelper.psm1" -Force
# 1) Set Deployment information
AzSet -App $App -Enviro D1
break
# F8 to run individual steps

# Export all role defintions per Subscription, only needed 1 time or when new roles added
. ADF:/1-prereqs/04.1-getRoleDefinitionTable.ps1 @Current


##########################################################
# Deploy Environment


AzSet -App $App -Enviro G0

# Global -
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/00-ALL-SUB.bicep -WhatIf
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/00-ALL-SUB.bicep


# 4) Set Deployment information - Dev Environment
AzSet -App $App -Enviro G1

# Global - Only Needed in secondary Region
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/00-ALL-SUB.bicep -WhatIf
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/00-ALL-SUB.bicep

AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/01-ALL-RG.bicep -WhatIf
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/01-ALL-RG.bicep

# 4) Set Deployment information - Dev Environment
AzSet -App $App -Enviro P0

# Global - Only Needed in secondary Region
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/00-ALL-SUB.bicep
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/01-ALL-RG.bicep

# Repeat above for other environments, however can do those in yaml pipelines instead

# Run an individual Deployment
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/VNET.bicep
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/KV.bicep
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/SA.bicep -DeploymentName cshell
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/VM.bicep -DeploymentName AppServers -CN CLIENT01

AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/AVDHostPool.bicep
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/AVDAppGroup.bicep
AzDeploy @Current -Prefix AEU1 -TF ADF:/bicep/AVDWorkspace.bicep