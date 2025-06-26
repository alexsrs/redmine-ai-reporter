# Variables for Terraform configuration

variable "environment_name" {
  description = "Nome do ambiente (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Localização dos recursos Azure"
  type        = string
  default     = "East US"
}

variable "resource_prefix" {
  description = "Prefixo para nomenclatura dos recursos"
  type        = string
  default     = "redmine-ai"
}

variable "app_name" {
  description = "Nome da app principal"
  type        = string
  default     = "redmine-ai-reporter"
}

variable "resource_group_name" {
  description = "Nome do Resource Group onde os recursos serão criados"
  type        = string
}
