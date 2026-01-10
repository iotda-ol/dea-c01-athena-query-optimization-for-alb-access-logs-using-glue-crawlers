# Amazon Athena Query Optimization for ALB Access Logs Using Glue Crawlers

## Overview

This repository demonstrates how to optimize Amazon Athena query performance for Application Load Balancer (ALB) access logs stored in Amazon S3. It uses AWS Glue crawlers with built-in classifiers to automatically detect schemas and add partitions to the AWS Glue Data Catalog, enabling efficient partition pruning with minimal operational effort.

## Architecture

```
┌─────────────┐
│     ALB     │
└──────┬──────┘
       │ Access Logs
       ▼
┌─────────────────────────────────────┐
│  S3 Bucket (Partitioned Structure)  │
│  /alb-logs/AWSLogs/.../YYYY/MM/DD/  │
└──────────────┬──────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│      AWS Glue Crawler                │
│  • Built-in ALB Classifier           │
│  • Automatic Schema Detection        │
│  • Automatic Partition Discovery     │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│    AWS Glue Data Catalog             │
│  • Database: alb_logs                │
│  • Table: alb_access_logs            │
│  • Partitions: year/month/day        │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│      Amazon Athena                   │
│  • Partition Pruning                 │
│  • Optimized Queries                 │
│  • Reduced Data Scanned              │
└──────────────────────────────────────┘
```

## Key Features

### 1. **Automatic Schema Detection**
- AWS Glue crawler uses built-in ALB log classifier
- No manual schema definition required
- Automatically detects all ALB log fields

### 2. **Automatic Partition Discovery**
- Crawler detects partition structure from S3 paths
- Automatically creates partitions for year/month/day
- No manual partition management needed

### 3. **Partition Pruning for Performance**
- Athena queries use partition filters to scan only relevant data
- Significantly reduces data scanned and query costs
- Improves query performance by orders of magnitude

### 4. **No Data Transformation Required**
- Queries original log files directly
- No ETL jobs or file format conversion
- Maintains original data in native format

## Why This Approach Minimizes Operational Effort (DEA-C01 Best Practices)

### Minimal Operational Effort Factors:

1. **No Manual Schema Management**
   - Glue crawler automatically detects ALB log schema
   - No need to write CREATE TABLE statements
   - Schema updates handled automatically

2. **Automatic Partition Discovery**
   - Crawler automatically discovers and adds new partitions
   - No manual MSCK REPAIR TABLE or ALTER TABLE ADD PARTITION commands
   - Scales automatically as new logs arrive

3. **No Data Transformation**
   - Query logs in original format (no Parquet/ORC conversion needed)
   - No ETL pipelines to build and maintain
   - No additional storage for transformed data
   - Lower cost and complexity

4. **Built-in ALB Classifier**
   - AWS Glue has pre-built classifier for ALB logs
   - No custom classifiers or SerDe configurations needed
   - Works out-of-the-box with standard ALB log format

5. **Serverless and Managed**
   - No servers to manage
   - No infrastructure to maintain
   - Pay only for what you use

### Performance Benefits:

| Query Type | Without Partitioning | With Partitioning | Improvement |
|------------|---------------------|-------------------|-------------|
| Single Day | Scans all data | Scans 1 day only | 99%+ reduction |
| Error Analysis | Full table scan | Partition-filtered | 10-100x faster |
| Cost per Query | Higher (more data) | Lower (less data) | Proportional to reduction |

### DEA-C01 Alignment:

This solution aligns with DEA-C01 (AWS Certified Data Engineer - Associate) best practices:

- **Data Store Management**: Leverages S3 partitioning for efficient data organization
- **Data Pipeline**: Uses serverless, managed services (Glue, Athena)
- **Operational Excellence**: Minimizes manual operations through automation
- **Cost Optimization**: Reduces costs through partition pruning
- **Performance Optimization**: Improves query performance without complex transformations

## Prerequisites

- AWS Account
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Application Load Balancer generating access logs (optional for testing)

## Deployment

### 1. Clone the Repository

```bash
git clone <repository-url>
cd dea-c01-athena-query-optimization-for-alb-access-logs-using-glue-crawlers
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review and Customize Variables (Optional)

Create a `terraform.tfvars` file:

```hcl
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "athena-alb-logs"
glue_crawler_schedule = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC
```

### 4. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### 5. Note Output Values

After deployment, Terraform outputs important values:

```bash
terraform output
```

## Usage

### Step 1: Upload Sample Logs (For Testing)

```bash
# Get the bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw alb_logs_bucket_name)

# Upload sample logs
./examples/upload-sample-logs.sh $BUCKET_NAME
```

### Step 2: Run Glue Crawler

```bash
# Get the crawler name from Terraform output
CRAWLER_NAME=$(terraform output -raw glue_crawler_name)

# Start the crawler
aws glue start-crawler --name $CRAWLER_NAME

# Check crawler status
aws glue get-crawler --name $CRAWLER_NAME
```

The crawler will:
1. Scan the S3 bucket
2. Detect ALB log format using built-in classifier
3. Create table schema in Glue Data Catalog
4. Add partitions for each date (year/month/day)

### Step 3: Query Data in Athena

#### Option A: Use AWS Console

1. Open Amazon Athena console
2. Select the workgroup: `athena-alb-logs-workgroup`
3. View saved queries in "Saved queries" tab
4. Run queries against the `alb_access_logs` table

#### Option B: Use AWS CLI

```bash
# Get workgroup and database names
WORKGROUP=$(terraform output -raw athena_workgroup_name)
DATABASE=$(terraform output -raw glue_database_name)

# Run a query
aws athena start-query-execution \
  --query-string "SELECT * FROM alb_access_logs LIMIT 10;" \
  --query-execution-context Database=$DATABASE \
  --work-group $WORKGROUP
```

### Example Queries

#### 1. Count Requests by Status Code (With Partition Pruning)

```sql
SELECT 
  target_status_code,
  COUNT(*) as request_count
FROM alb_access_logs
WHERE year = '2024' 
  AND month = '12'
  AND day = '16'
GROUP BY target_status_code
ORDER BY request_count DESC;
```

**Benefits**: Scans only data for December 16, 2024

#### 2. Top Requested URLs

```sql
SELECT 
  request_url,
  COUNT(*) as request_count,
  AVG(target_processing_time) as avg_processing_time
FROM alb_access_logs
WHERE year = '2024' 
  AND month = '12'
  AND day = '16'
GROUP BY request_url
ORDER BY request_count DESC
LIMIT 20;
```

#### 3. Error Analysis (4xx and 5xx Errors)

```sql
SELECT 
  target_status_code,
  request_url,
  COUNT(*) as error_count
FROM alb_access_logs
WHERE year = '2024' 
  AND month = '12'
  AND day = '16'
  AND (target_status_code BETWEEN 400 AND 499 
       OR target_status_code BETWEEN 500 AND 599)
GROUP BY target_status_code, request_url
ORDER BY error_count DESC
LIMIT 50;
```

#### 4. Show Available Partitions

```sql
SHOW PARTITIONS alb_access_logs;
```

### Performance Comparison

To demonstrate the benefit of partition pruning, compare these two queries:

**With Partition Pruning** (Fast):
```sql
SELECT COUNT(*) FROM alb_access_logs
WHERE year = '2024' AND month = '12' AND day = '16';
```

**Without Partition Pruning** (Slow):
```sql
SELECT COUNT(*) FROM alb_access_logs
WHERE time >= '2024-12-16T00:00:00Z' 
  AND time < '2024-12-17T00:00:00Z';
```

The first query scans only partitioned data, while the second scans all data.

## Monitoring and Maintenance

### Crawler Schedule

The Glue crawler runs automatically based on the schedule (default: daily at 2 AM UTC). To modify:

```hcl
# In terraform.tfvars
glue_crawler_schedule = "cron(0 6 * * ? *)"  # Daily at 6 AM UTC
```

Or disable automatic scheduling:

```hcl
glue_crawler_schedule = ""
```

### Manual Crawler Execution

Run the crawler manually when needed:

```bash
aws glue start-crawler --name $(terraform output -raw glue_crawler_name)
```

### View Glue Table Details

```bash
aws glue get-table \
  --database-name $(terraform output -raw glue_database_name) \
  --name alb_access_logs
```

### View Partitions

```bash
aws glue get-partitions \
  --database-name $(terraform output -raw glue_database_name) \
  --table-name alb_access_logs
```

## Cost Optimization

### Athena Query Costs

- Charged per data scanned: $5 per TB
- Partition pruning reduces data scanned by 90-99%
- Example: Querying 1 day of logs instead of 1 year (365x reduction)

### S3 Storage Costs

- Standard S3 storage: ~$0.023 per GB/month
- Lifecycle policy automatically deletes logs after 90 days

### Glue Crawler Costs

- $0.44 per DPU-Hour
- Typical run: 0.1 DPU-Hours = ~$0.044 per run
- Daily runs: ~$1.32/month

## Troubleshooting

### Crawler Not Finding Data

1. Verify logs are in correct path structure:
   ```
   s3://bucket/alb-logs/AWSLogs/123456789012/elasticloadbalancing/region/YYYY/MM/DD/
   ```

2. Check S3 bucket policy allows Glue access

3. Verify IAM role permissions

### Athena Query Errors

1. **"Table not found"**: Run Glue crawler first
2. **"Partition not found"**: Ensure crawler has completed successfully
3. **"Access Denied"**: Check S3 bucket permissions and Athena results location

### No Partitions Created

1. Ensure S3 path follows ALB log structure
2. Check Glue crawler configuration
3. View crawler logs in CloudWatch

## Clean Up

To avoid ongoing charges, destroy all resources:

```bash
terraform destroy
```

Note: This will delete all S3 buckets and their contents (due to `force_destroy = true`).

## Files Structure

```
.
├── README.md                 # This file
├── main.tf                   # Terraform provider configuration
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── s3.tf                     # S3 bucket resources
├── iam.tf                    # IAM roles and policies
├── glue.tf                   # Glue database and crawler
├── athena.tf                 # Athena workgroup and queries
├── .gitignore               # Git ignore patterns
└── examples/
    ├── sample-logs/
    │   └── sample-alb-log.log  # Sample ALB log file
    └── upload-sample-logs.sh   # Script to upload sample logs
```

## Key Terraform Resources

- `aws_s3_bucket.alb_logs` - S3 bucket for ALB access logs
- `aws_s3_bucket.athena_results` - S3 bucket for Athena query results
- `aws_glue_catalog_database.alb_logs` - Glue database
- `aws_glue_crawler.alb_logs` - Glue crawler for automatic schema/partition detection
- `aws_athena_workgroup.alb_logs` - Athena workgroup
- `aws_athena_named_query.*` - Pre-configured sample queries

## Additional Resources

- [AWS Glue Crawler Documentation](https://docs.aws.amazon.com/glue/latest/dg/add-crawler.html)
- [Amazon Athena Best Practices](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning.html)
- [ALB Access Logs Format](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
- [Partition Projection in Athena](https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html)

## License

This project is provided as-is for educational and demonstration purposes.
