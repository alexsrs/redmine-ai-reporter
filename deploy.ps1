#!/usr/bin/env pwsh
# Deploy script for Redmine AI Reporter - Terraform
# Optimized for Azure free tier resources

param(
    [switch]$PlanOnly = $false,
    [switch]$Destroy = $false,
    [string]$Environment = "dev"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Blue
Write-Host "    REDMINE AI REPORTER - DEPLOY       " -ForegroundColor Blue  
Write-Host "         Terraform + Azure             " -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# Function to write colored output
function Write-Step($Message) {
    Write-Host "=> $Message" -ForegroundColor Blue
}

function Write-Success($Message) {
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host "! $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "X $Message" -ForegroundColor Red
}

# Check prerequisites
Write-Step "Verificando pré-requisitos..."

# Check Azure CLI
try {
    az --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Azure CLI encontrado"
    } else {
        throw "Azure CLI não encontrado"
    }
} catch {
    Write-Error "Azure CLI não está instalado. Instale com: winget install Microsoft.AzureCLI"
    exit 1
}

# Check Terraform
try {
    terraform --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Terraform encontrado"
    } else {
        throw "Terraform não encontrado"
    }
} catch {
    Write-Error "Terraform não está instalado. Download: https://developer.hashicorp.com/terraform/install"
    exit 1
}

# Check Azure login
Write-Step "Verificando login do Azure..."
try {
    $accountJson = az account show --output json 2>$null
    if ($accountJson) {
        $account = $accountJson | ConvertFrom-Json
        Write-Success "Logado como: $($account.user.name)"
        Write-Success "Subscription: $($account.name)"
    } else {
        throw "Não logado"
    }
} catch {
    Write-Error "Não está logado no Azure. Execute: az login"
    exit 1
}

# Change to infra directory
Write-Step "Navegando para o diretório de infraestrutura..."
Set-Location -Path "infra"

if ($Destroy) {
    Write-Warning "MODO DESTRUIÇÃO ATIVADO!"
    Write-Host "Isso irá DESTRUIR todos os recursos do Azure."
    $confirm = Read-Host "Digite 'DESTROY' para confirmar"
    
    if ($confirm -eq "DESTROY") {
        Write-Step "Destruindo infraestrutura..."
        terraform destroy -auto-approve
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Infraestrutura destruída com sucesso!"
        } else {
            Write-Error "Erro ao destruir a infraestrutura"
            exit 1
        }
    } else {
        Write-Warning "Destruição cancelada"
        exit 0
    }
    
    Set-Location -Path ".."
    exit 0
}

# Initialize Terraform
Write-Step "Inicializando Terraform..."
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Error "Erro ao inicializar Terraform"
    Set-Location -Path ".."
    exit 1
}

Write-Success "Terraform inicializado com sucesso"

# Validate configuration
Write-Step "Validando configuração Terraform..."
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Error "Configuração Terraform inválida"
    Set-Location -Path ".."
    exit 1
}

Write-Success "Configuração validada com sucesso"

# Plan deployment
Write-Step "Criando plano de deployment..."
terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Error "Erro ao criar plano de deployment"
    Set-Location -Path ".."
    exit 1
}

Write-Success "Plano criado com sucesso"

# If plan-only mode, stop here
if ($PlanOnly) {
    Write-Success "Modo 'Plan Only' - parando aqui"
    Write-Host ""
    Write-Host "Para aplicar as mudanças, execute:" -ForegroundColor Yellow
    Write-Host "  .\deploy.ps1" -ForegroundColor Yellow
    Write-Host ""
    Set-Location -Path ".."
    exit 0
}

# Apply deployment
Write-Warning "Aplicando mudanças no Azure..."
Write-Host "Isso criará recursos no Azure que podem gerar custos."
$confirm = Read-Host "Continuar? (y/N)"

if ($confirm -eq "y" -or $confirm -eq "Y") {
    Write-Step "Aplicando deployment..."
    terraform apply tfplan
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Deploy concluído com sucesso!"
        Write-Host ""
        
        # Get outputs
        Write-Step "Obtendo informações dos recursos criados..."
        Write-Host ""
        Write-Host "RECURSOS CRIADOS:" -ForegroundColor Green
        Write-Host ""
        
        try {
            $resourceGroup = terraform output -raw resource_group_name 2>$null
            $staticWebApp = terraform output -raw static_web_app_url 2>$null
            $functionApp = terraform output -raw function_app_name 2>$null
            $keyVault = terraform output -raw key_vault_name 2>$null
            $storageAccount = terraform output -raw storage_account_name 2>$null
            
            if ($resourceGroup) { Write-Host "Resource Group: $resourceGroup" }
            if ($staticWebApp) { Write-Host "Static Web App: $staticWebApp" }
            if ($functionApp) { Write-Host "Function App: $functionApp" }
            if ($keyVault) { Write-Host "Key Vault: $keyVault" }
            if ($storageAccount) { Write-Host "Storage Account: $storageAccount" }
        } catch {
            Write-Warning "Não foi possível obter todas as informações dos recursos"
        }
        
        Write-Host ""
        Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Yellow
        Write-Host "1. Configure o Azure OpenAI no Key Vault"
        Write-Host "2. Teste a aplicação"
        Write-Host "3. Configure o CI/CD"
        Write-Host ""
        Write-Host "Consulte a documentação em docs/ para mais detalhes" -ForegroundColor Blue
        
    } else {
        Write-Error "Erro durante o deployment"
        Set-Location -Path ".."
        exit 1
    }
} else {
    Write-Warning "Deployment cancelado"
}

# Return to root directory
Set-Location -Path ".."

Write-Host ""
Write-Success "Script concluído!"
Write-Host ""
