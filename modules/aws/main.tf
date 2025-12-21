# AWS Module for ALB Access Logs Analysis
# Provides: S3, Glue, Athena infrastructure for log analysis

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DEA-C01-Athena-Optimization"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "AWS"
    }
  }
}
