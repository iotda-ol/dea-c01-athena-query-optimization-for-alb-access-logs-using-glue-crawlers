# Production Environment Configuration
aws_region            = "us-east-1"
environment           = "prod"
project_name          = "athena-alb-logs"
glue_crawler_schedule = "cron(0 1 * * ? *)" # Run daily at 1 AM UTC
