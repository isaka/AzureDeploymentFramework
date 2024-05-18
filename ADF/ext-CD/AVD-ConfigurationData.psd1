#
# ConfigurationData.psd1
#

@{ 
    AllNodes = @( 
        @{ 
            NodeName                    = 'LocalHost' 
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true

            DSCConfigurationMode        = 'ApplyOnly'

            # IncludesAllSubfeatures
            # WindowsFeaturePresent       = @('Web-Server')

            DirectoryPresent            = @(
                'C:\Source\Logs\AVD\azcopy_logs'
            )

            # Blob copy with Managed Identity - Oauth2
            AZCOPYDSCDirPresentSource  = @(
                @{
                    SourcePathBlobURI = 'https://{0}.blob.core.windows.net/source/AVD/'
                    DestinationPath   = 'C:\Source\AVD\'
                    LogDir            = 'C:\Source\Logs\AVD\azcopy_logs'
                }
            )

            AVDInstall                  = @(
                @{
                    PoolNameSuffix = 'BPO01'
                    PackagePath    = 'C:\Source\AVD\Microsoft.RDInfra.RDAgent.Installer-x64-1.0.7539.8300.msi'
                    LogDirectory   = 'C:\Source\Logs\AVD'
                }
            )

            SoftwarePackagePresent      = @(
                @{
                    Name      = 'Remote Desktop Agent Boot Loader'
                    Path      = 'C:\Source\AVD\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi'
                    ProductId = '{4B380ECF-71DB-4BEC-921A-AEFD534C9E5C}'
                    Arguments = '/log "C:\Source\Logs\AVD\AgentBootLoaderInstall.txt"'
                } 
            )
        } 
    )
}









































