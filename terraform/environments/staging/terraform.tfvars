# Staging Environment Configuration
aws_region            = "us-east-1"
environment           = "staging"
project_name          = "athena-alb-logs"
glue_crawler_schedule = "cron(0 2 * * ? *)" # Run daily at 2 AM UTC
