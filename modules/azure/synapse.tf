# Synapse Analytics Workspace for log analysis
resource "azurerm_synapse_workspace" "lb_logs" {
  name                                 = "${var.project_name}-synapse-${var.environment}"
  resource_group_name                  = azurerm_resource_group.lb_logs.name
  location                             = azurerm_resource_group.lb_logs.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "P@ssw0rd123!" # In production, use Azure Key Vault

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

# Data Lake Gen2 Filesystem for Synapse
resource "azurerm_storage_data_lake_gen2_filesystem" "synapse" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.lb_logs.id
}

# Synapse SQL Pool (optional, commented out to reduce costs)
# resource "azurerm_synapse_sql_pool" "lb_logs" {
#   name                 = "lblogssqlpool"
#   synapse_workspace_id = azurerm_synapse_workspace.lb_logs.id
#   sku_name             = "DW100c"
#   create_mode          = "Default"
# }

# Synapse Spark Pool for data processing
resource "azurerm_synapse_spark_pool" "lb_logs" {
  name                 = "lblogssparkpool"
  synapse_workspace_id = azurerm_synapse_workspace.lb_logs.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"

  auto_scale {
    max_node_count = 3
    min_node_count = 3
  }

  auto_pause {
    delay_in_minutes = 15
  }

  tags = {
    Environment = var.environment
  }
}
