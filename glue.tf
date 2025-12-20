# Glue Catalog Database
resource "aws_glue_catalog_database" "alb_logs" {
  name        = "${var.project_name}_database"
  description = "Database for ALB access logs with automatic partitioning"
}

# Glue Crawler for ALB access logs
# Uses built-in ALB classifier to automatically detect schema and partitions
resource "aws_glue_crawler" "alb_logs" {
  name          = "${var.project_name}-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.alb_logs.name
  description   = "Crawler for ALB access logs with automatic partition detection"

  # Target S3 path for ALB logs
  s3_target {
    path = "s3://${aws_s3_bucket.alb_logs.id}/alb-logs/"
  }

  # Configure the crawler to use built-in classifiers
  # ALB logs follow a specific format that Glue can automatically detect
  classifiers = []

  # Schema change policy - update table and add new columns
  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  # Configuration for automatic partitioning
  # Glue will detect partition structure from S3 path
  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  # Recrawl policy - crawl everything on each run to detect new partitions
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  # LineageConfiguration - disable for performance
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }

  # Schedule (optional) - can be set to run periodically
  schedule = var.glue_crawler_schedule != "" ? var.glue_crawler_schedule : null

  tags = {
    Name = "${var.project_name}-crawler"
  }
}
