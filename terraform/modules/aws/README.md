# AWS Module

This module provisions AWS infrastructure for analyzing Application Load Balancer (ALB) access logs using managed services.

## Resources Created

- **S3 Buckets**:
  - ALB logs bucket (with partitioning support)
  - Athena query results bucket
  
- **AWS Glue**:
  - Glue Catalog Database
  - Glue Crawler (with built-in ALB classifier)
  
- **IAM Resources**:
  - Glue Crawler execution role
  - S3 access policies
  
- **Amazon Athena**:
  - Athena Workgroup
  - Sample named queries

## Usage

### Basic Deployment

```bash
cd modules/aws
terraform init
terraform plan
terraform apply
```

### With Custom Variables

```hcl
# terraform.tfvars
aws_region            = "us-west-2"
environment           = "prod"
project_name          = "my-project"
glue_crawler_schedule = "cron(0 6 * * ? *)"  # Daily at 6 AM UTC
```

```bash
terraform apply -var-file="terraform.tfvars"
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aws_region | AWS region for resources | string | us-east-1 | no |
| environment | Environment name | string | dev | no |
| project_name | Project name for resource naming | string | athena-alb-logs | no |
| glue_crawler_schedule | Cron expression for crawler | string | cron(0 2 * * ? *) | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_logs_bucket_name | Name of the S3 bucket for ALB logs |
| athena_results_bucket_name | Name of the S3 bucket for Athena results |
| glue_database_name | Name of the Glue database |
| glue_crawler_name | Name of the Glue crawler |
| athena_workgroup_name | Name of the Athena workgroup |

## Architecture

```
ALB → S3 Bucket → Glue Crawler → Glue Catalog → Athena → Results S3
```

## Cost Estimate

Based on 100GB logs, 30 crawler runs, 300GB scanned:
- S3: ~$2.30/month
- Glue Crawler: ~$1.32/month
- Athena: ~$1.50/month
- **Total: ~$5/month**

## Security

### Current Implementation
- S3 buckets have public access blocked
- Server-side encryption enabled (SSE-S3 with AES256)
- IAM roles follow least privilege principle
- Lifecycle policies for data retention
- Versioning enabled on critical buckets

### Production Recommendations
Consider upgrading to AWS KMS for enhanced security:

```hcl
# Upgrade to KMS encryption for production
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}
```

**Benefits of KMS encryption:**
- Enhanced key management and rotation
- Detailed audit trails via CloudTrail
- Fine-grained access control
- Compliance with regulatory requirements
- Integration with AWS Security Hub

### Additional Security Best Practices
- Enable S3 bucket logging
- Configure AWS CloudTrail for API auditing
- Use VPC endpoints for private S3 access
- Implement bucket policies with explicit deny rules
- Enable MFA delete for critical buckets
- Regular security assessments with AWS Config

## Examples

### Start Glue Crawler

```bash
CRAWLER_NAME=$(terraform output -raw glue_crawler_name)
aws glue start-crawler --name $CRAWLER_NAME
```

### Query with Athena

```sql
SELECT 
  target_status_code,
  COUNT(*) as request_count
FROM alb_access_logs
WHERE year = '2024' 
  AND month = '12'
  AND day = '21'
GROUP BY target_status_code;
```

## Related Documentation

- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [Amazon Athena Documentation](https://docs.aws.amazon.com/athena/)
- [ALB Access Logs Format](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
