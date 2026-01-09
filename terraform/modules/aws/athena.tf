# Athena Workgroup for ALB log queries
resource "aws_athena_workgroup" "alb_logs" {
  name        = "${var.project_name}-workgroup"
  description = "Workgroup for querying ALB access logs with partition pruning"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.id}/query-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    engine_version {
      selected_engine_version = "AUTO"
    }
  }

  tags = {
    Name = "${var.project_name}-workgroup"
  }
}

# Named Query: Count requests by status code with partition filtering
resource "aws_athena_named_query" "count_by_status" {
  name        = "count_requests_by_status_code"
  description = "Count requests by status code for a specific date (demonstrates partition pruning)"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- Example query demonstrating partition pruning
    -- Replace year, month, day with actual partition values
    SELECT 
      target_status_code,
      COUNT(*) as request_count
    FROM alb_access_logs
    WHERE year = '2024' 
      AND month = '12'
      AND day = '16'
    GROUP BY target_status_code
    ORDER BY request_count DESC;
  EOQ
}

# Named Query: Top requested URLs with partition filtering
resource "aws_athena_named_query" "top_urls" {
  name        = "top_requested_urls"
  description = "Find top requested URLs for a specific date range"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- Query top requested URLs with partition filtering
    SELECT 
      request_url,
      COUNT(*) as request_count,
      AVG(target_processing_time) as avg_processing_time,
      MAX(target_processing_time) as max_processing_time
    FROM alb_access_logs
    WHERE year = '2024' 
      AND month = '12'
      AND day = '16'
    GROUP BY request_url
    ORDER BY request_count DESC
    LIMIT 20;
  EOQ
}

# Named Query: Error analysis with partition filtering
resource "aws_athena_named_query" "error_analysis" {
  name        = "error_analysis"
  description = "Analyze 4xx and 5xx errors for a specific date"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- Analyze errors with partition filtering
    SELECT 
      target_status_code,
      request_url,
      COUNT(*) as error_count
    FROM alb_access_logs
    WHERE year = '2024' 
      AND month = '12'
      AND day = '16'
      AND (target_status_code BETWEEN 400 AND 499 
           OR target_status_code BETWEEN 500 AND 599)
    GROUP BY target_status_code, request_url
    ORDER BY error_count DESC
    LIMIT 50;
  EOQ
}

# Named Query: Traffic analysis by hour with partition filtering
resource "aws_athena_named_query" "traffic_by_hour" {
  name        = "traffic_by_hour"
  description = "Analyze traffic patterns by hour for a specific date"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- Analyze traffic by hour with partition filtering
    SELECT 
      date_format(from_iso8601_timestamp(time), '%Y-%m-%d %H:00:00') as hour,
      COUNT(*) as request_count,
      AVG(target_processing_time) as avg_response_time,
      SUM(sent_bytes + received_bytes) as total_bytes
    FROM alb_access_logs
    WHERE year = '2024' 
      AND month = '12'
      AND day = '16'
    GROUP BY date_format(from_iso8601_timestamp(time), '%Y-%m-%d %H:00:00')
    ORDER BY hour;
  EOQ
}

# Named Query: Full table scan comparison (without partition filtering)
resource "aws_athena_named_query" "full_scan_comparison" {
  name        = "full_scan_comparison"
  description = "Example of query WITHOUT partition pruning (slower, scans all data)"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- This query does NOT use partition pruning - scans all data
    -- Use this to compare performance with partitioned queries
    SELECT 
      target_status_code,
      COUNT(*) as request_count
    FROM alb_access_logs
    WHERE time >= '2024-12-16T00:00:00Z' 
      AND time < '2024-12-17T00:00:00Z'
    GROUP BY target_status_code
    ORDER BY request_count DESC;
  EOQ
}

# Named Query: Show available partitions
resource "aws_athena_named_query" "show_partitions" {
  name        = "show_partitions"
  description = "List all available partitions in the table"
  workgroup   = aws_athena_workgroup.alb_logs.id
  database    = aws_glue_catalog_database.alb_logs.name

  query = <<-EOQ
    -- Show all available partitions
    SHOW PARTITIONS alb_access_logs;
  EOQ
}
