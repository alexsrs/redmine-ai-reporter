# Backend configuration for Terraform state
# Uncomment and configure for production deployments

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "terraformstate<unique_suffix>"
#     container_name       = "tfstate"
#     key                  = "redmine-ai-reporter.terraform.tfstate"
#   }
# }
