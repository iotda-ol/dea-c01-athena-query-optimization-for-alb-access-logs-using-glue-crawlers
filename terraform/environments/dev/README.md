# Development Environment

This directory contains the Terraform configuration for the **development** environment.

## Configuration

- **Environment**: dev
- **AWS Region**: us-east-1
- **Project Name**: athena-alb-logs
- **Glue Crawler Schedule**: Daily at 2 AM UTC

## Quick Start

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply

# Destroy resources when done
terraform destroy
```

## Customization

Edit `terraform.tfvars` to customize the configuration:

```hcl
aws_region            = "us-east-1"
environment           = "dev"
project_name          = "athena-alb-logs"
glue_crawler_schedule = "cron(0 2 * * ? *)"
```

## Outputs

After deployment, you'll receive:
- S3 bucket name for ALB logs
- Athena workgroup name
- Glue database name
- Glue crawler name
