# Azure Module

This module provisions Azure infrastructure for analyzing load balancer logs using Synapse Analytics.

## Resources Created

- **Storage**:
  - Storage accounts for logs and results
  - Blob containers
  - Lifecycle management policies
  
- **Synapse Analytics**:
  - Synapse workspace
  - Spark pool for data processing
  - Data Lake Gen2 filesystem

## Usage

### Basic Deployment

```bash
cd modules/azure
terraform init
terraform plan
terraform apply
```

### With Custom Variables

```hcl
# terraform.tfvars
azure_subscription_id = "your-subscription-id"
azure_location        = "westus2"
environment           = "prod"
project_name          = "loganalysis"
resource_group_name   = "rg-logs-prod"
log_retention_days    = 180
```

```bash
terraform apply -var-file="terraform.tfvars"
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| azure_subscription_id | Azure Subscription ID | string | - | yes |
| azure_location | Azure location | string | eastus | no |
| environment | Environment name | string | dev | no |
| project_name | Project name | string | loganalysis | no |
| resource_group_name | Resource group name | string | rg-log-analysis | no |
| log_retention_days | Log retention in days | number | 90 | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Resource group name |
| storage_account_name | Storage account for LB logs |
| storage_container_name | Blob container for logs |
| synapse_workspace_name | Synapse workspace name |
| synapse_spark_pool_name | Spark pool name |
| query_results_storage_account | Storage account for results |

## Architecture

```
Azure LB → Blob Storage → Synapse Workspace → Spark Pool → Results Storage
```

## Cost Estimate

Based on 100GB logs, 10 Spark pool hours:
- Blob Storage: ~$1.84/month
- Synapse Spark Pool: ~$15.00/month
- **Total: ~$17/month**

> Note: Costs can be reduced by using on-demand Spark pools

## Features

### Auto-Pause

```hcl
auto_pause {
  delay_in_minutes = 15
}
```

### Auto-Scale

```hcl
auto_scale {
  max_node_count = 3
  min_node_count = 3
}
```

### Lifecycle Management

```hcl
rule {
  name    = "delete-old-logs"
  enabled = true
  
  actions {
    base_blob {
      delete_after_days_since_modification_greater_than = 90
    }
  }
}
```

## Examples

### Query with Synapse SQL

```sql
SELECT 
  status_code,
  COUNT(*) as request_count
FROM OPENROWSET(
  BULK 'https://storage.blob.core.windows.net/logs/*.log',
  FORMAT = 'CSV'
) AS logs
GROUP BY status_code;
```

### Upload Data

```bash
az storage blob upload \
  --account-name lblogsstorage \
  --container-name lb-logs \
  --file data.log \
  --name data.log
```

## Security

- Storage accounts use LRS replication
- Private access only
- Lifecycle policies for retention
- Data Lake Gen2 for hierarchical namespace

## Related Documentation

- [Azure Synapse Documentation](https://docs.microsoft.com/azure/synapse-analytics/)
- [Blob Storage Documentation](https://docs.microsoft.com/azure/storage/blobs/)
- [Spark Pool Best Practices](https://docs.microsoft.com/azure/synapse-analytics/spark/apache-spark-pool-configurations)
