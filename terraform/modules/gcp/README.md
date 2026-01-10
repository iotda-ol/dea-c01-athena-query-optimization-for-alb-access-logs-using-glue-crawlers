# GCP Module

This module provisions GCP infrastructure for analyzing load balancer logs using BigQuery.

## Resources Created

- **Cloud Storage**:
  - LB logs bucket
  - Query results bucket
  
- **BigQuery**:
  - Dataset for log analysis
  - Partitioned and clustered table

## Usage

### Basic Deployment

```bash
cd modules/gcp
terraform init
terraform plan
terraform apply
```

### With Custom Variables

```hcl
# terraform.tfvars
gcp_project_id    = "my-project-id"
gcp_region        = "us-west1"
environment       = "prod"
project_name      = "my-logs"
log_retention_days = 180
```

```bash
terraform apply -var-file="terraform.tfvars"
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| gcp_project_id | GCP Project ID | string | - | yes |
| gcp_region | GCP region | string | us-central1 | no |
| environment | Environment name | string | dev | no |
| project_name | Project name | string | log-analysis | no |
| dataset_location | BigQuery dataset location | string | US | no |
| log_retention_days | Log retention in days | number | 90 | no |

## Outputs

| Name | Description |
|------|-------------|
| lb_logs_bucket_name | Cloud Storage bucket for LB logs |
| query_results_bucket_name | Cloud Storage bucket for results |
| bigquery_dataset_id | BigQuery dataset ID |
| bigquery_table_id | BigQuery table ID |
| bigquery_table_full_id | Full BigQuery table identifier |

## Architecture

```
Cloud LB → Cloud Storage → BigQuery Table (partitioned) → Query Results
```

## Cost Estimate

Based on 100GB logs, 300GB processed:
- Cloud Storage: ~$2.00/month
- BigQuery Storage: ~$2.00/month
- BigQuery Queries: ~$1.50/month
- **Total: ~$5.50/month**

## Features

### Time Partitioning

```hcl
time_partitioning {
  type  = "DAY"
  field = "timestamp"
}
```

### Clustering

```hcl
clustering = ["client_ip", "lb_status_code"]
```

## Examples

### Query Data

```sql
SELECT 
  lb_status_code,
  COUNT(*) as request_count
FROM `project-id.dataset.table`
WHERE DATE(timestamp) = '2024-12-21'
GROUP BY lb_status_code;
```

### Load Data

```bash
bq load --source_format=CSV \
  dataset.table \
  gs://bucket/logs/*.log \
  schema.json
```

## Related Documentation

- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Partitioning Best Practices](https://cloud.google.com/bigquery/docs/partitioned-tables)
