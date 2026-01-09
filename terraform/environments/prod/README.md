# Production Environment

This directory contains the Terraform configuration for the **production** environment.

## Configuration

- **Environment**: prod
- **AWS Region**: us-east-1
- **Project Name**: athena-alb-logs
- **Glue Crawler Schedule**: Daily at 1 AM UTC

## ⚠️ Important - Production Notes

- State management should use remote backend (S3 + DynamoDB)
- Uncomment backend configuration in `main.tf` before deploying
- Ensure proper IAM permissions are in place
- Review all changes carefully before applying
- Use approval workflows for production changes

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
