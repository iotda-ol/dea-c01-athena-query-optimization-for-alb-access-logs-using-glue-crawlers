# Quick Start Guide

Get up and running with the ALB log query optimization solution in under 10 minutes!

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform installed (>= 1.0)

## Step-by-Step Deployment

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd dea-c01-athena-query-optimization-for-alb-access-logs-using-glue-crawlers
```

### 2. Initialize Terraform

```bash
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

### 3. Review Configuration (Optional)

```bash
terraform plan
```

This shows what resources will be created.

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~2-3 minutes.

### 5. Save Output Values

```bash
# Save bucket name for later use
BUCKET_NAME=$(terraform output -raw alb_logs_bucket_name)
CRAWLER_NAME=$(terraform output -raw glue_crawler_name)
WORKGROUP_NAME=$(terraform output -raw athena_workgroup_name)

echo "Bucket: $BUCKET_NAME"
echo "Crawler: $CRAWLER_NAME"
echo "Workgroup: $WORKGROUP_NAME"
```

### 6. Upload Sample Logs

```bash
./examples/upload-sample-logs.sh $BUCKET_NAME
```

### 7. Run Glue Crawler

```bash
aws glue start-crawler --name $CRAWLER_NAME
```

Check status:
```bash
aws glue get-crawler --name $CRAWLER_NAME | jq '.Crawler.State'
```

Wait until status is `READY` (takes ~1-2 minutes).

### 8. Query Data in Athena

#### Option A: AWS Console

1. Open [Athena Console](https://console.aws.amazon.com/athena/)
2. Select workgroup (output from step 5)
3. Select database: `athena-alb-logs_database`
4. Click "Saved queries" to see example queries
5. Run a query!

#### Option B: AWS CLI

```bash
# Run a simple query
aws athena start-query-execution \
  --query-string "SELECT COUNT(*) FROM alb_access_logs WHERE year='2024' AND month='12' AND day='16';" \
  --query-execution-context Database=athena-alb-logs_database \
  --result-configuration OutputLocation=s3://$BUCKET_NAME/query-results/ \
  --work-group $WORKGROUP_NAME
```

## Verify Everything Works

### Check 1: S3 Bucket Created

```bash
aws s3 ls | grep athena-alb-logs
```

Expected: Two buckets (alb-logs and athena-results)

### Check 2: Glue Database Created

```bash
aws glue get-database --name athena-alb-logs_database
```

Expected: Database details in JSON

### Check 3: Glue Table Created (After Crawler Runs)

```bash
aws glue get-table --database-name athena-alb-logs_database --name alb_access_logs
```

Expected: Table schema with ALB log columns

### Check 4: Partitions Exist (After Crawler Runs)

```bash
aws glue get-partitions --database-name athena-alb-logs_database --table-name alb_access_logs
```

Expected: At least one partition for today's date

## Example Queries

### Query 1: Count All Records

```sql
SELECT COUNT(*) as total_requests
FROM alb_access_logs
WHERE year = '2024' AND month = '12' AND day = '16';
```

### Query 2: Status Code Distribution

```sql
SELECT 
  target_status_code,
  COUNT(*) as count
FROM alb_access_logs
WHERE year = '2024' AND month = '12' AND day = '16'
GROUP BY target_status_code
ORDER BY count DESC;
```

### Query 3: Top URLs

```sql
SELECT 
  request_url,
  COUNT(*) as hits
FROM alb_access_logs
WHERE year = '2024' AND month = '12' AND day = '16'
GROUP BY request_url
ORDER BY hits DESC
LIMIT 10;
```

### Query 4: Show Partitions

```sql
SHOW PARTITIONS alb_access_logs;
```

## Troubleshooting

### Issue: Crawler Fails

**Check logs**:
```bash
aws logs tail /aws-glue/crawlers --follow
```

**Common causes**:
- No data in S3 bucket
- IAM permissions missing
- Incorrect S3 path

**Solution**: Verify logs uploaded and check IAM role

### Issue: Table Not Found in Athena

**Check if crawler completed**:
```bash
aws glue get-crawler --name $CRAWLER_NAME | jq '.Crawler.LastCrawl'
```

**Solution**: Wait for crawler to finish, then refresh Athena console

### Issue: No Partitions Found

**Check S3 path structure**:
```bash
aws s3 ls s3://$BUCKET_NAME/alb-logs/ --recursive
```

**Expected structure**:
```
alb-logs/AWSLogs/123456789012/elasticloadbalancing/us-east-1/2024/12/16/
```

**Solution**: Ensure logs follow correct path structure

### Issue: Access Denied in Athena

**Check workgroup**:
```bash
aws athena get-work-group --work-group $WORKGROUP_NAME
```

**Solution**: Use the correct workgroup in Athena console

## Next Steps

### 1. Connect Real ALB

Configure your ALB to send logs to the S3 bucket:

```bash
aws elbv2 modify-load-balancer-attributes \
  --load-balancer-arn <your-alb-arn> \
  --attributes \
    Key=access_logs.s3.enabled,Value=true \
    Key=access_logs.s3.bucket,Value=$BUCKET_NAME \
    Key=access_logs.s3.prefix,Value=alb-logs
```

### 2. Schedule Crawler

The crawler runs daily at 2 AM UTC by default. To change:

```hcl
# In terraform.tfvars
glue_crawler_schedule = "cron(0 6 * * ? *)"  # 6 AM UTC
```

Then:
```bash
terraform apply
```

### 3. Create Dashboards

Connect Amazon QuickSight:
1. Open QuickSight console
2. Create new dataset
3. Select Athena as source
4. Choose `alb_access_logs` table
5. Build visualizations

### 4. Set Up Alerts

Create CloudWatch alarm for errors:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name alb-high-error-rate \
  --alarm-description "Alert when 5xx errors exceed threshold" \
  --metric-name target_status_code \
  --namespace ALB \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold
```

## Performance Tips

1. **Always use partition filters**:
   ```sql
   WHERE year = '2024' AND month = '12' AND day = '16'
   ```

2. **Select specific columns**:
   ```sql
   SELECT time, request_url, target_status_code  -- Good
   -- Not: SELECT *  -- Bad
   ```

3. **Limit results when exploring**:
   ```sql
   SELECT * FROM alb_access_logs LIMIT 10;
   ```

4. **Use saved queries**: They're optimized and tested

## Cost Monitoring

### Check Athena Costs

```bash
# Get query execution details
aws athena get-query-execution --query-execution-id <execution-id>
```

Look for `DataScannedInBytes` in output.

**Formula**: Cost = (DataScannedInBytes / 1TB) * $5

### Estimate Monthly Costs

For 100 GB logs, 10 queries/day:
- S3 storage: $2.30/month
- Glue crawler: $1.32/month
- Athena queries: $1.50/month
- **Total: ~$5/month**

## Cleanup

When done testing:

```bash
terraform destroy
```

Type `yes` to confirm. This deletes:
- S3 buckets and all contents
- Glue database and tables
- Athena workgroup
- IAM roles

**Warning**: This is irreversible!

## Getting Help

### Documentation
- [Full README](./README.md)
- [Architecture Details](./ARCHITECTURE.md)
- [DEA-C01 Best Practices](./DEA-C01-BEST-PRACTICES.md)

### AWS Documentation
- [Athena](https://docs.aws.amazon.com/athena/)
- [Glue Crawler](https://docs.aws.amazon.com/glue/latest/dg/add-crawler.html)
- [ALB Logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)

### Common Commands Reference

```bash
# Terraform
terraform init          # Initialize
terraform plan          # Preview changes
terraform apply         # Deploy
terraform destroy       # Delete everything
terraform output        # Show outputs

# Glue
aws glue start-crawler --name <crawler-name>
aws glue get-crawler --name <crawler-name>
aws glue get-table --database-name <db> --name <table>

# Athena
aws athena start-query-execution --query-string "<sql>" --work-group <wg>
aws athena get-query-execution --query-execution-id <id>

# S3
aws s3 ls s3://<bucket>/
aws s3 cp <file> s3://<bucket>/<path>
```

## Success Checklist

- [ ] Terraform initialized and applied successfully
- [ ] S3 buckets created (2 buckets)
- [ ] Glue database created
- [ ] Glue crawler created
- [ ] Sample logs uploaded to S3
- [ ] Glue crawler ran successfully
- [ ] Table `alb_access_logs` exists
- [ ] Partitions created (at least 1)
- [ ] Athena query executed successfully
- [ ] Query results returned data

**If all checked, congratulations! 🎉 Your solution is working!**

## What You've Learned

- ✅ How to set up Athena for log analysis
- ✅ How to use Glue crawlers for schema detection
- ✅ How partitioning improves query performance
- ✅ How to query ALB logs with SQL
- ✅ DEA-C01 best practices for minimal operational effort

Ready to apply this to production? Review [README.md](./README.md) for production considerations.
