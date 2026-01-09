# Terraform Infrastructure

This directory contains all Terraform infrastructure-as-code for the multi-cloud log analysis platform.

## Directory Structure

```
terraform/
├── main.tf                    # Root module orchestrating all components
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── environments/              # Environment-specific configurations
│   ├── dev/                  # Development environment
│   ├── staging/              # Staging environment
│   └── prod/                 # Production environment
└── modules/                   # Reusable Terraform modules
    ├── aws/                  # AWS-specific resources
    ├── gcp/                  # GCP-specific resources
    ├── azure/                # Azure-specific resources
    └── common/               # Shared/common resources
```

## Usage

### Deploy to Development
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy to Staging
```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

### Deploy to Production
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## Modules

Each cloud provider has its own module:
- **AWS**: S3 buckets, Glue crawlers, Athena workgroups
- **GCP**: Cloud Storage, BigQuery
- **Azure**: Blob Storage, Synapse Analytics
- **Common**: Shared naming conventions and utilities

## Best Practices

1. Always run `terraform plan` before `terraform apply`
2. Use environment-specific configurations for each deployment
3. Store production state remotely (S3 backend for AWS)
4. Tag all resources appropriately
5. Use workspaces for environment isolation
