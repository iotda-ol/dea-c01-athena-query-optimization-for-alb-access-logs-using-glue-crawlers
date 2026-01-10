# Production Environment Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "athena-alb-logs"
}

variable "glue_crawler_schedule" {
  description = "Cron expression for Glue Crawler schedule (empty string to disable)"
  type        = string
  default     = "cron(0 1 * * ? *)" # Run daily at 1 AM UTC
}
