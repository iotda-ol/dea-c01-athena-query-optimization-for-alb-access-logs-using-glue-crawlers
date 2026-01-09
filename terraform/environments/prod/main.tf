# Production Environment
# This configuration uses the root terraform module with production-specific settings

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment for production state management
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "prod/athena-alb-logs/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Configure AWS provider for production
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Project     = "athena-alb-logs"
    }
  }
}

# Use the main terraform configuration
module "infrastructure" {
  source = "../.."
  
  aws_region            = var.aws_region
  environment           = var.environment
  project_name          = var.project_name
  glue_crawler_schedule = var.glue_crawler_schedule
}

# Re-export outputs
output "aws_alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB logs"
  value       = module.infrastructure.aws_alb_logs_bucket_name
}

output "aws_athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = module.infrastructure.aws_athena_workgroup_name
}

output "aws_glue_database_name" {
  description = "Name of the Glue database"
  value       = module.infrastructure.aws_glue_database_name
}

output "aws_glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.infrastructure.aws_glue_crawler_name
}
