// Main Bicep template para o Redmine AI Reporter
// Otimizado para usar serviços gratuitos do Azure

// Parâmetros
@description('Nome do ambiente (ex: dev, staging, prod)')
param environmentName string = 'dev'

@description('Localização dos recursos Azure')
param location string = resourceGroup().location

@description('Prefixo para nomenclatura dos recursos')
param resourcePrefix string = 'redmine-ai'

@description('Token único para nomenclatura de recursos')
param resourceToken string = toLower(uniqueString(subscription().id, resourceGroup().id, environmentName))

@description('Nome da app principal')
param appName string = 'redmine-ai-reporter'

// Variáveis derivadas
var tags = {
  'azd-env-name': environmentName
  'app-name': appName
  'project': 'redmine-ai-reporter'
  'cost-center': 'development'
  'environment': environmentName
}

var resourceNames = {
  // Storage Account para logs e evidências
  storageAccount: '${resourcePrefix}${resourceToken}st'
  // Static Web App para frontend
  staticWebApp: '${resourcePrefix}-${resourceToken}-swa'
  // Function App para API
  functionApp: '${resourcePrefix}-${resourceToken}-func'
  // App Service Plan
  appServicePlan: '${resourcePrefix}-${resourceToken}-asp'
  // Key Vault para secrets
  keyVault: '${resourcePrefix}-${resourceToken}-kv'
  // Application Insights
  appInsights: '${resourcePrefix}-${resourceToken}-ai'
  // Log Analytics Workspace
  logAnalytics: '${resourcePrefix}-${resourceToken}-log'
  // Managed Identity
  managedIdentity: '${resourcePrefix}-${resourceToken}-mi'
}

// === RECURSOS ===

// 1. Managed Identity (User-Assigned)
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: resourceNames.managedIdentity
  location: location
  tags: tags
}

// 2. Log Analytics Workspace (para Application Insights)
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: resourceNames.logAnalytics
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018' // Pay-as-you-go pricing
    }
    retentionInDays: 30 // Minimum retention
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// 3. Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: resourceNames.appInsights
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// 4. Storage Account (Free Tier)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: resourceNames.storageAccount
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS' // Locally redundant storage (free tier)
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    accessTier: 'Hot'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// 5. Key Vault para armazenar secrets
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: resourceNames.keyVault
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard' // Standard tier para o plano gratuito
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: ['get', 'list']
        }
      }
    ]
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7 // Minimum retention
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// 6. App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: resourceNames.appServicePlan
  location: location
  tags: tags
  sku: {
    name: 'Y1' // Consumption plan (gratuito para Functions)
  }
  kind: 'functionapp'
  properties: {
    reserved: false
  }
}

// 7. Function App para API
resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: resourceNames.functionApp
  location: location
  tags: union(tags, {
    'azd-service-name': 'api'
  })
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}deployments'
          authentication: {
            type: 'UserAssignedIdentity'
            userAssignedIdentityResourceId: managedIdentity.id
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 200
        instanceMemoryMB: 2048
      }
      runtime: {
        name: 'node'
        version: '20'
      }
    }
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: ['*']
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: managedIdentity.properties.clientId
        }
        {
          name: 'KEY_VAULT_URI'
          value: keyVault.properties.vaultUri
        }
      ]
    }
  }
}

// 8. Static Web App para Frontend
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: resourceNames.staticWebApp
  location: location
  tags: union(tags, {
    'azd-service-name': 'frontend'
  })
  sku: {
    name: 'Free' // Free tier
  }
  properties: {
    buildProperties: {
      skipGithubActionWorkflowGeneration: false
      appLocation: '/src/frontend'
      apiLocation: ''
      outputLocation: 'dist'
    }
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// 9. Role Assignments para Managed Identity

// Storage Blob Data Contributor role para o Function App
resource storageBlobDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentity.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Queue Data Contributor role
resource storageQueueDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentity.id, '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Table Data Contributor role
resource storageTableDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentity.id, '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Monitoring Metrics Publisher role
resource monitoringMetricsPublisherRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appInsights.id, managedIdentity.id, '3913510d-42f4-4e42-8a64-420c390055eb')
  scope: appInsights
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// === OUTPUTS ===
output RESOURCE_GROUP_ID string = resourceGroup().id
output resourceGroupName string = resourceGroup().name
output environmentName string = environmentName
output appName string = appName

// Static Web App outputs
output AZURE_STATIC_WEB_APP_NAME string = staticWebApp.name
output AZURE_STATIC_WEB_APP_URL string = 'https://${staticWebApp.properties.defaultHostname}'

// Function App outputs
output AZURE_FUNCTION_APP_NAME string = functionApp.name
output AZURE_FUNCTION_APP_URL string = 'https://${functionApp.properties.defaultHostName}'

// Storage outputs
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name

// Key Vault outputs
output AZURE_KEY_VAULT_NAME string = keyVault.name
output AZURE_KEY_VAULT_URI string = keyVault.properties.vaultUri

// Application Insights outputs
output AZURE_APPLICATION_INSIGHTS_NAME string = appInsights.name
output AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING string = appInsights.properties.ConnectionString

// Managed Identity outputs
output AZURE_MANAGED_IDENTITY_NAME string = managedIdentity.name
output AZURE_MANAGED_IDENTITY_CLIENT_ID string = managedIdentity.properties.clientId
