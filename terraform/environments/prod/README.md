# Production Environment

This directory contains the Terraform configuration for the **production** environment.

## Configuration

- **Environment**: prod
- **AWS Region**: us-east-1
- **Project Name**: athena-alb-logs
- **Glue Crawler Schedule**: Daily at 1 AM UTC

## ⚠️ Important - Production Notes

- **State management**: Remote backend is commented out by default
- **REQUIRED before production deployment**: Uncomment and configure the S3 backend
- Ensure proper IAM permissions are in place
- Review all changes carefully before applying
- Use approval workflows for production changes
- **Never commit sensitive values** to version control

### Backend Configuration Steps

1. Create S3 bucket for state storage:
   ```bash
   aws s3 mb s3://your-terraform-state-bucket --region us-east-1
   ```

2. Create DynamoDB table for state locking:
   ```bash
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

3. Uncomment the backend configuration in `main.tf`

4. Initialize with remote backend:
   ```bash
   terraform init -migrate-state
   ```

## Quick Start

```bash
# Initialize Terraform with remote backend
terraform init

# Review the execution plan
terraform plan

# Apply the configuration (requires approval)
terraform apply

# Never destroy production without team approval!
# terraform destroy
```

## Customization

Edit `terraform.tfvars` to customize the configuration:

```hcl
aws_region            = "us-east-1"
environment           = "prod"
project_name          = "athena-alb-logs"
glue_crawler_schedule = "cron(0 1 * * ? *)"
```

## Remote State Configuration

Before deploying to production, configure the remote backend in `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "prod/athena-alb-logs/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## Outputs

After deployment, you'll receive:
- S3 bucket name for ALB logs
- Athena workgroup name
- Glue database name
- Glue crawler name
