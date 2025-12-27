output "name_prefix" {
  description = "Standardized naming prefix for resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags to be applied to all resources"
  value       = local.common_tags
}

output "bucket_suffix" {
  description = "Random suffix for globally unique bucket names"
  value       = local.bucket_suffix
}
