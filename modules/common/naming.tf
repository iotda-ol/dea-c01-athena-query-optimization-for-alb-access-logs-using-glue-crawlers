# Common naming conventions
locals {
  # Standardized naming pattern: {project}-{resource}-{environment}
  name_prefix = "${var.project_name}-${var.environment}"

  # Standard tags applied across all resources
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # Resource naming helpers
  bucket_suffix = random_id.bucket_suffix.hex
}

# Random suffix for globally unique names (e.g., S3 buckets)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
