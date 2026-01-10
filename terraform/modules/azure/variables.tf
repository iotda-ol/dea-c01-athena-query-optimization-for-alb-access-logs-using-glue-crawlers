variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure location for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "loganalysis"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-log-analysis"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
}

variable "synapse_sql_admin_password" {
  description = "SQL administrator password for Synapse workspace. Should be stored in Azure Key Vault or as a secure environment variable."
  type        = string
  sensitive   = true
  default     = null
}
