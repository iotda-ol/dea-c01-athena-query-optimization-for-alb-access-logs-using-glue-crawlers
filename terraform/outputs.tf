output "alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.id
}

output "athena_results_bucket_name" {
  description = "Name of the S3 bucket for Athena query results"
  value       = aws_s3_bucket.athena_results.id
}

output "glue_database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.alb_logs.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.alb_logs.name
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.alb_logs.name
}

output "glue_table_name" {
  description = "Name of the Glue table created by the crawler"
  value       = "alb_access_logs"
}

output "sample_athena_query" {
  description = "Sample Athena query using partition pruning"
  value       = <<-EOT
    SELECT 
      request_url,
      target_status_code,
      COUNT(*) as request_count
    FROM ${aws_glue_catalog_database.alb_logs.name}.alb_access_logs
    WHERE year = '2024' 
      AND month = '12'
      AND day = '16'
    GROUP BY request_url, target_status_code
    ORDER BY request_count DESC
    LIMIT 10;
  EOT
}

output "deployment_instructions" {
  description = "Instructions for deploying and using the solution"
  value       = <<-EOT
    1. Upload ALB logs to: s3://${aws_s3_bucket.alb_logs.id}/alb-logs/
    2. Run the Glue Crawler: aws glue start-crawler --name ${aws_glue_crawler.alb_logs.name}
    3. Query data in Athena using workgroup: ${aws_athena_workgroup.alb_logs.name}
    4. View table in Glue Console: Database '${aws_glue_catalog_database.alb_logs.name}', Table 'alb_access_logs'
  EOT
}
