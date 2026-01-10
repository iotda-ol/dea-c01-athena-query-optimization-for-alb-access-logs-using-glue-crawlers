output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lb_logs.name
}

output "storage_account_name" {
  description = "Name of the storage account for LB logs"
  value       = azurerm_storage_account.lb_logs.name
}

output "storage_container_name" {
  description = "Name of the storage container for LB logs"
  value       = azurerm_storage_container.raw_logs.name
}

output "synapse_workspace_name" {
  description = "Name of the Synapse workspace"
  value       = azurerm_synapse_workspace.lb_logs.name
}

output "synapse_spark_pool_name" {
  description = "Name of the Synapse Spark pool"
  value       = azurerm_synapse_spark_pool.lb_logs.name
}

output "query_results_storage_account" {
  description = "Name of the storage account for query results"
  value       = azurerm_storage_account.query_results.name
}

output "synapse_sql_admin_password" {
  description = "SQL administrator password for Synapse workspace (sensitive)"
  value       = var.synapse_sql_admin_password != null ? var.synapse_sql_admin_password : random_password.synapse_admin.result
  sensitive   = true
}
