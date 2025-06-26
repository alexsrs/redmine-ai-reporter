# Deploy script for Redmine AI Reporter using Terraform
# This script helps deploy the infrastructure to Azure

param(
    [switch]$AutoApprove,
    [switch]$PlanOnly
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-ColoredMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-ColoredMessage "🚀 Redmine AI Reporter - Terraform Deploy Script" $Blue
Write-Host

# Check prerequisites
Write-ColoredMessage "📋 Checking prerequisites..." $Yellow

if (-not (Test-CommandExists "terraform")) {
    Write-ColoredMessage "❌ Terraform is not installed. Please install Terraform first." $Red
    Write-ColoredMessage "💡 You can install it using: winget install Hashicorp.Terraform" $Blue
    exit 1
}

if (-not (Test-CommandExists "az")) {
    Write-ColoredMessage "❌ Azure CLI is not installed. Please install Azure CLI first." $Red
    Write-ColoredMessage "💡 You can install it using: winget install Microsoft.AzureCLI" $Blue
    exit 1
}

Write-ColoredMessage "✅ Prerequisites check passed" $Green
Write-Host

# Check if user is logged in to Azure
Write-ColoredMessage "🔐 Checking Azure login status..." $Yellow
try {
    az account show 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Not logged in"
    }
}
catch {
    Write-ColoredMessage "❌ You are not logged in to Azure" $Red
    Write-ColoredMessage "💡 Please run: az login" $Blue
    exit 1
}

Write-ColoredMessage "✅ Azure login confirmed" $Green
Write-Host

# Get current directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$InfraDir = Join-Path $ScriptDir "infra"

# Change to infrastructure directory
Set-Location $InfraDir

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-ColoredMessage "⚠️  terraform.tfvars not found. Creating from example..." $Yellow
    
    if (Test-Path "terraform.tfvars.example") {
        Copy-Item "terraform.tfvars.example" "terraform.tfvars"
        Write-ColoredMessage "📝 Please edit terraform.tfvars with your specific values" $Blue
        Write-ColoredMessage "💡 Especially set the resource_group_name variable" $Blue
        Write-Host
        
        if (-not $AutoApprove) {
            Read-Host "Press Enter after editing terraform.tfvars to continue"
        }
    }
    else {
        Write-ColoredMessage "❌ terraform.tfvars.example not found" $Red
        exit 1
    }
}

# Initialize Terraform
Write-ColoredMessage "🏗️  Initializing Terraform..." $Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-ColoredMessage "❌ Terraform init failed" $Red
    exit 1
}

# Validate Terraform configuration
Write-ColoredMessage "✅ Validating Terraform configuration..." $Yellow
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-ColoredMessage "❌ Terraform validate failed" $Red
    exit 1
}

# Plan the deployment
Write-ColoredMessage "📋 Planning Terraform deployment..." $Yellow
terraform plan

if ($LASTEXITCODE -ne 0) {
    Write-ColoredMessage "❌ Terraform plan failed" $Red
    exit 1
}

# Exit if plan only
if ($PlanOnly) {
    Write-ColoredMessage "📋 Plan completed. Exiting as requested." $Blue
    exit 0
}

# Ask for confirmation unless auto-approve is set
if (-not $AutoApprove) {
    Write-Host
    $confirmation = Read-Host "Do you want to apply these changes? (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-ColoredMessage "🚫 Deployment cancelled" $Yellow
        exit 0
    }
}

# Apply the configuration
Write-ColoredMessage "🚀 Applying Terraform configuration..." $Yellow
if ($AutoApprove) {
    terraform apply -auto-approve
}
else {
    terraform apply
}

if ($LASTEXITCODE -ne 0) {
    Write-ColoredMessage "❌ Terraform apply failed" $Red
    exit 1
}

# Get outputs
Write-ColoredMessage "📤 Getting deployment outputs..." $Yellow
Write-Host
Write-ColoredMessage "✅ Deployment completed successfully!" $Green
Write-Host
Write-ColoredMessage "📊 Deployment Information:" $Blue

try {
    $resourceGroup = terraform output -r resource_group_name
    $staticWebAppUrl = terraform output -r AZURE_STATIC_WEB_APP_URL
    $functionAppUrl = terraform output -r AZURE_FUNCTION_APP_URL
    $keyVaultName = terraform output -r AZURE_KEY_VAULT_NAME
    
    Write-Host "Resource Group: $resourceGroup"
    Write-Host "Static Web App: $staticWebAppUrl"
    Write-Host "Function App: $functionAppUrl"
    Write-Host "Key Vault: $keyVaultName"
}
catch {
    Write-ColoredMessage "⚠️  Could not retrieve all outputs" $Yellow
}

Write-Host

# Provide next steps
Write-ColoredMessage "🎯 Next Steps:" $Blue
Write-Host "1. Configure your Static Web App deployment token"
Write-Host "2. Configure your Function App publish profile"
Write-Host "3. Set up your CI/CD secrets in GitHub"
Write-Host "4. Deploy your application code"
Write-Host
Write-ColoredMessage "🎉 Infrastructure is ready!" $Green

# Open Azure Portal
if (-not $AutoApprove) {
    $openPortal = Read-Host "Open Azure Portal to view resources? (y/N)"
    if ($openPortal -eq 'y' -or $openPortal -eq 'Y') {
        try {
            $resourceGroup = terraform output -r resource_group_name
            $resourceId = az group show --name $resourceGroup --query "id" -o tsv
            Start-Process "https://portal.azure.com/#@/resource$resourceId"
        }
        catch {
            Write-ColoredMessage "⚠️  Could not open Azure Portal automatically" $Yellow
        }
    }
}
