# Architecture Deep Dive

## Solution Architecture

This solution implements a serverless, automated approach to querying ALB access logs using AWS managed services.

## Components

### 1. Amazon S3 (Data Storage)

**ALB Logs Bucket**
- Stores raw ALB access logs in their native format
- Organized with date-based partitioning structure:
  ```
  s3://bucket/alb-logs/AWSLogs/{account-id}/elasticloadbalancing/{region}/{year}/{month}/{day}/
  ```
- Lifecycle policy: Automatically delete logs after 90 days
- Encryption: Server-side encryption (SSE-S3)
- Public access: Blocked

**Athena Results Bucket**
- Stores Athena query results
- Lifecycle policy: Delete results after 30 days
- Encryption: SSE-S3

### 2. AWS Glue Data Catalog

**Database**: `athena-alb-logs_database`
- Central metadata repository
- Stores table schemas and partition information
- Integrates with Athena for query execution

**Table**: `alb_access_logs`
- Created automatically by Glue crawler
- Contains schema detected from ALB logs
- Partition keys: year, month, day

### 3. AWS Glue Crawler

**Purpose**: Automate schema discovery and partition management

**Configuration**:
- **Target**: S3 path with ALB logs
- **Classifier**: Built-in ALB log classifier (automatic detection)
- **Schedule**: Daily at 2 AM UTC (configurable)
- **Recrawl Policy**: CRAWL_EVERYTHING (finds new partitions)

**What it does**:
1. Scans S3 bucket for ALB log files
2. Uses built-in classifier to detect ALB log format
3. Infers schema from log structure
4. Detects partition structure from S3 paths
5. Creates/updates table in Glue Data Catalog
6. Adds new partitions automatically

### 4. Amazon Athena

**Workgroup**: `athena-alb-logs-workgroup`
- Dedicated workgroup for ALB log queries
- Output location configured
- CloudWatch metrics enabled

**Query Engine**:
- Serverless SQL query engine
- Uses Presto under the hood
- Queries data directly in S3
- Leverages Glue Data Catalog for metadata

## Data Flow

```
1. ALB generates access logs
   ↓
2. Logs stored in S3 with partition structure (/YYYY/MM/DD/)
   ↓
3. Glue Crawler runs (scheduled or manual)
   ↓
4. Crawler detects schema and partitions
   ↓
5. Table and partitions created/updated in Glue Data Catalog
   ↓
6. Users query via Athena
   ↓
7. Athena uses partition filters to scan only relevant data
   ↓
8. Results stored in Athena results bucket
```

## Partition Strategy

### Why Partitioning?

Partitioning organizes data into hierarchical folders based on key values (year, month, day). Benefits:

1. **Partition Pruning**: Athena skips irrelevant partitions
2. **Reduced Data Scanned**: Query only necessary dates
3. **Lower Costs**: Pay for less data scanned
4. **Faster Queries**: Less data to process

### ALB Log Partition Structure

ALB automatically creates logs with this structure:

```
alb-logs/AWSLogs/123456789012/elasticloadbalancing/us-east-1/
  ├── 2024/
  │   ├── 12/
  │   │   ├── 15/
  │   │   │   └── logs_20241215.log
  │   │   ├── 16/
  │   │   │   └── logs_20241216.log
  │   │   └── 17/
  │   │       └── logs_20241217.log
```

Glue crawler detects this structure and creates partitions:
- `year=2024/month=12/day=15`
- `year=2024/month=12/day=16`
- `year=2024/month=12/day=17`

### Query Example with Partitions

**With Partition Pruning** (Efficient):
```sql
SELECT * FROM alb_access_logs
WHERE year = '2024' AND month = '12' AND day = '16';
```
→ Scans only data in the 2024/12/16 partition

**Without Partition Pruning** (Inefficient):
```sql
SELECT * FROM alb_access_logs
WHERE time >= '2024-12-16' AND time < '2024-12-17';
```
→ Scans all partitions, then filters results

## Built-in ALB Classifier

AWS Glue includes a pre-built classifier for ALB access logs.

### What it Detects:

The classifier recognizes the ALB log format and extracts fields:

- `type` - Protocol (http, https, h2, ws, wss)
- `time` - Timestamp
- `elb` - Load balancer name
- `client_ip` - Client IP and port
- `target_ip` - Target IP and port
- `request_processing_time` - Time to receive request
- `target_processing_time` - Time to process request
- `response_processing_time` - Time to send response
- `elb_status_code` - Load balancer status code
- `target_status_code` - Target status code
- `received_bytes` - Bytes received
- `sent_bytes` - Bytes sent
- `request_verb` - HTTP method
- `request_url` - Request URL
- `request_proto` - HTTP version
- `user_agent` - Client user agent
- And many more fields...

### No Manual Configuration Required

Unlike custom log formats, you don't need to:
- Define SerDe (Serializer/Deserializer)
- Specify regex patterns
- Create custom classifiers
- Write CREATE TABLE statements

## Comparison: This Approach vs. Alternatives

### Alternative 1: Manual Table Creation

**Traditional Approach**:
1. Write CREATE TABLE statement with schema
2. Manually run MSCK REPAIR TABLE or ADD PARTITION
3. Repeat for each new date

**Our Approach**:
1. Run Glue crawler (automatic or scheduled)
2. Everything else is automatic

### Alternative 2: ETL to Parquet/ORC

**ETL Approach**:
1. Set up Glue ETL jobs
2. Convert logs to Parquet/ORC
3. Store transformed data
4. Manage ETL pipeline

**Pros**: Better compression, faster queries
**Cons**: More operational overhead, ETL costs, storage costs

**Our Approach**:
1. Query logs directly in original format
2. No ETL pipeline to maintain
3. Lower operational overhead

**Trade-off**: Slightly slower queries, but minimal operational effort

### Alternative 3: Partition Projection

**Partition Projection Approach**:
- Define partition schema in table properties
- Athena generates partitions on-the-fly
- No crawler needed

**Our Approach**:
- Uses crawler for flexibility
- Works with any partition structure
- Easier to understand and troubleshoot

## Security

### S3 Bucket Security
- Public access blocked
- Server-side encryption enabled
- Bucket policy limits access to ALB service

### IAM Roles
- Glue crawler has minimal required permissions
- Follows principle of least privilege
- Separate role for each service

### Athena Security
- Query results encrypted
- Workgroup configuration enforced
- CloudWatch metrics for monitoring

## Cost Analysis

### Components and Pricing

1. **S3 Storage**
   - Standard: $0.023 per GB/month
   - Example: 100 GB logs = $2.30/month

2. **Glue Crawler**
   - $0.44 per DPU-Hour
   - Daily run: ~0.1 DPU-Hours = $0.044
   - Monthly: ~$1.32

3. **Athena Queries**
   - $5 per TB scanned
   - Example: 10 queries/day, 1 GB scanned each = 300 GB/month = $1.50/month
   - With partitioning vs. without: 90-99% cost reduction

4. **Glue Data Catalog**
   - First million objects: Free
   - $1 per 100,000 objects above 1 million

**Total Estimated Cost** (for 100 GB logs, 10 queries/day):
- S3: $2.30
- Glue Crawler: $1.32
- Athena: $1.50
- **Total: ~$5/month**

### Cost Optimization Tips

1. Use partition filters in all queries
2. Limit columns selected (SELECT specific columns, not *)
3. Set lifecycle policies to delete old data
4. Use Athena query result reuse
5. Consider disabling crawler schedule if logs are infrequent

## Performance Considerations

### Query Performance Factors

1. **Partition Pruning** (Most Important)
   - Always filter by year, month, day
   - Can reduce data scanned by 99%

2. **Column Selection**
   - SELECT specific columns, not SELECT *
   - Reduces data transfer

3. **Data Format**
   - Native ALB logs (this solution): Good performance
   - Parquet/ORC: Better performance, but requires ETL

4. **Compression**
   - ALB logs are typically gzip compressed
   - Athena handles decompression automatically

### Benchmark Example

**Scenario**: Query 1 year of logs (365 days, 10 GB/day, 3.65 TB total)

| Query Type | Data Scanned | Query Time | Cost |
|------------|--------------|------------|------|
| Full scan (no partitions) | 3.65 TB | ~60 seconds | $18.25 |
| Single day (with partitions) | 10 GB | ~2 seconds | $0.05 |
| Single month (with partitions) | 300 GB | ~10 seconds | $1.50 |

**Improvement**: 365x reduction in data scanned and costs!

## Scalability

### Horizontal Scaling
- S3 scales automatically
- Glue crawler handles large datasets
- Athena scales compute automatically

### Large Datasets
- Solution works with petabytes of data
- Partition strategy prevents performance degradation
- Consider partition projection for extremely large datasets

### High Query Volume
- Athena handles concurrent queries
- Consider query result caching
- Use workgroups to manage concurrency

## Monitoring and Observability

### CloudWatch Metrics

**Glue Crawler**:
- `glue.driver.aggregate.numCompletedTables`
- `glue.driver.aggregate.numFailedTasks`

**Athena**:
- `DataScannedInBytes`
- `EngineExecutionTime`
- `QuerySucceeded`
- `QueryFailed`

### Logging

**Glue Crawler Logs**:
- Location: CloudWatch Logs `/aws-glue/crawlers`
- Contains crawler execution details

**Athena Query History**:
- Available in Athena Console
- Shows query execution details, data scanned, costs

### Alerts (Optional Enhancement)

Consider setting up CloudWatch alarms for:
- Crawler failures
- Excessive data scanned
- Query failures
- High costs

## Future Enhancements

### 1. Partition Projection
For very large datasets, consider switching to partition projection:
```sql
CREATE EXTERNAL TABLE alb_access_logs (...)
PARTITIONED BY (year string, month string, day string)
LOCATION 's3://bucket/alb-logs/'
TBLPROPERTIES (
  'projection.enabled' = 'true',
  'projection.year.type' = 'integer',
  'projection.year.range' = '2020,2030',
  'projection.month.type' = 'integer',
  'projection.month.range' = '1,12',
  'projection.day.type' = 'integer',
  'projection.day.range' = '1,31'
);
```

### 2. Data Lake Integration
- Integrate with AWS Lake Formation
- Add fine-grained access controls
- Enable cross-account access

### 3. BI Tool Integration
- Connect Amazon QuickSight
- Create dashboards for log analysis
- Schedule automated reports

### 4. Advanced Analytics
- Anomaly detection using Athena ML
- Predictive analytics
- Real-time alerting

### 5. Cost Optimization
- Implement query result caching
- Use S3 Intelligent-Tiering
- Convert to Parquet for frequently queried data

## Conclusion

This architecture provides a balance of:
- **Simplicity**: Minimal configuration and maintenance
- **Performance**: Efficient queries through partitioning
- **Cost-effectiveness**: Pay only for what you use
- **Scalability**: Handles growing data volumes
- **Automation**: Self-maintaining through Glue crawler

Perfect for DEA-C01 scenarios emphasizing operational efficiency and AWS best practices.
