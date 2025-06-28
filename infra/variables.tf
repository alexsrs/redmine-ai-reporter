# ========================================
# VARIABLES - FREE TIER CONFIGURATION
# ========================================

variable "resource_group_name" {
  description = "Nome do resource group (deve ser único)"
  type        = string
  default     = "rg-redmine-ai-reporter"
  
  validation {
    condition     = length(var.resource_group_name) > 3 && length(var.resource_group_name) < 64
    error_message = "Resource group name deve ter entre 3 e 63 caracteres."
  }
}

variable "location" {
  description = "Localização dos recursos Azure (FREE tier disponível)"
  type        = string
  default     = "East US 2"
  
  validation {
    condition = contains([
      "East US",
      "East US 2", 
      "West US 2",
      "West Europe",
      "North Europe",
      "Southeast Asia"
    ], var.location)
    error_message = "Localização deve ser uma região com FREE tier disponível."
  }
}
