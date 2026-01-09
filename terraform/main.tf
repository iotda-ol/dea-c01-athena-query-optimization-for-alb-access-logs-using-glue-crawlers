terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Multi-cloud infrastructure composer
# This is the root module that orchestrates AWS, GCP, and Azure modules

# AWS Module - ALB Access Logs with Athena & Glue
module "aws_alb_logs" {
  source = "./modules/aws"

  aws_region            = var.aws_region
  environment           = var.environment
  project_name          = var.project_name
  glue_crawler_schedule = var.glue_crawler_schedule
}

# Outputs from AWS module
output "aws_alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB logs"
  value       = module.aws_alb_logs.alb_logs_bucket_name
}

output "aws_athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = module.aws_alb_logs.athena_workgroup_name
}

output "aws_glue_database_name" {
  description = "Name of the Glue database"
  value       = module.aws_alb_logs.glue_database_name
}

output "aws_glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.aws_alb_logs.glue_crawler_name
}
