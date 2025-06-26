#!/bin/bash

# Deploy script for Redmine AI Reporter using Terraform
# This script helps deploy the infrastructure to Azure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_message $BLUE "🚀 Redmine AI Reporter - Terraform Deploy Script"
echo

# Check prerequisites
print_message $YELLOW "📋 Checking prerequisites..."

if ! command_exists terraform; then
    print_message $RED "❌ Terraform is not installed. Please install Terraform first."
    print_message $BLUE "💡 You can install it using: winget install Hashicorp.Terraform"
    exit 1
fi

if ! command_exists az; then
    print_message $RED "❌ Azure CLI is not installed. Please install Azure CLI first."
    print_message $BLUE "💡 You can install it using: winget install Microsoft.AzureCLI"
    exit 1
fi

print_message $GREEN "✅ Prerequisites check passed"
echo

# Check if user is logged in to Azure
print_message $YELLOW "🔐 Checking Azure login status..."
if ! az account show >/dev/null 2>&1; then
    print_message $RED "❌ You are not logged in to Azure"
    print_message $BLUE "💡 Please run: az login"
    exit 1
fi

print_message $GREEN "✅ Azure login confirmed"
echo

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$SCRIPT_DIR/infra"

# Change to infrastructure directory
cd "$INFRA_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_message $YELLOW "⚠️  terraform.tfvars not found. Creating from example..."
    
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_message $BLUE "📝 Please edit terraform.tfvars with your specific values"
        print_message $BLUE "💡 Especially set the resource_group_name variable"
        echo
        read -p "Press Enter after editing terraform.tfvars to continue..."
    else
        print_message $RED "❌ terraform.tfvars.example not found"
        exit 1
    fi
fi

# Initialize Terraform
print_message $YELLOW "🏗️  Initializing Terraform..."
terraform init

# Validate Terraform configuration
print_message $YELLOW "✅ Validating Terraform configuration..."
terraform validate

# Plan the deployment
print_message $YELLOW "📋 Planning Terraform deployment..."
terraform plan

# Ask for confirmation
echo
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_message $YELLOW "🚫 Deployment cancelled"
    exit 0
fi

# Apply the configuration
print_message $YELLOW "🚀 Applying Terraform configuration..."
terraform apply -auto-approve

# Get outputs
print_message $YELLOW "📤 Getting deployment outputs..."
echo
print_message $GREEN "✅ Deployment completed successfully!"
echo
print_message $BLUE "📊 Deployment Information:"
echo "Resource Group: $(terraform output -raw resource_group_name)"
echo "Static Web App: $(terraform output -raw AZURE_STATIC_WEB_APP_URL)"
echo "Function App: $(terraform output -raw AZURE_FUNCTION_APP_URL)"
echo "Key Vault: $(terraform output -raw AZURE_KEY_VAULT_NAME)"
echo

# Provide next steps
print_message $BLUE "🎯 Next Steps:"
echo "1. Configure your Static Web App deployment token"
echo "2. Configure your Function App publish profile"
echo "3. Set up your CI/CD secrets in GitHub"
echo "4. Deploy your application code"
echo
print_message $GREEN "🎉 Infrastructure is ready!"

# Open Azure Portal
read -p "Open Azure Portal to view resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    az group show --name "$RESOURCE_GROUP" --query "id" -o tsv | xargs -I {} open "https://portal.azure.com/#@/resource{}"
fi
