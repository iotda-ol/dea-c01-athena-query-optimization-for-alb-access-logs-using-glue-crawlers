# Resource Group
resource "azurerm_resource_group" "lb_logs" {
  name     = var.resource_group_name
  location = var.azure_location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Module      = "Azure"
  }
}

# Storage Account for load balancer logs
resource "azurerm_storage_account" "lb_logs" {
  name                     = "${var.project_name}lblogs${var.environment}"
  resource_group_name      = azurerm_resource_group.lb_logs.name
  location                 = azurerm_resource_group.lb_logs.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = false

    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = var.environment
    Purpose     = "LoadBalancerLogs"
  }
}

# Container for raw logs
resource "azurerm_storage_container" "raw_logs" {
  name                  = "lb-logs"
  storage_account_name  = azurerm_storage_account.lb_logs.name
  container_access_type = "private"
}

# Storage Account for query results
resource "azurerm_storage_account" "query_results" {
  name                     = "${var.project_name}queryres${var.environment}"
  resource_group_name      = azurerm_resource_group.lb_logs.name
  location                 = azurerm_resource_group.lb_logs.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    Environment = var.environment
    Purpose     = "QueryResults"
  }
}

# Container for query results
resource "azurerm_storage_container" "query_results" {
  name                  = "query-results"
  storage_account_name  = azurerm_storage_account.query_results.name
  container_access_type = "private"
}

# Lifecycle management for logs
resource "azurerm_storage_management_policy" "lb_logs" {
  storage_account_id = azurerm_storage_account.lb_logs.id

  rule {
    name    = "delete-old-logs"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_retention_days
      }
    }
  }
}

# Lifecycle management for query results
resource "azurerm_storage_management_policy" "query_results" {
  storage_account_id = azurerm_storage_account.query_results.id

  rule {
    name    = "delete-old-results"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
    }
  }
}
