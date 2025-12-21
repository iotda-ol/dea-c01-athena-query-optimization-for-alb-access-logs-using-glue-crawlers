# Cloud Storage bucket for load balancer logs
resource "google_storage_bucket" "lb_logs" {
  name          = "${var.project_name}-lb-logs-${var.gcp_project_id}"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = false
  }
}

# Cloud Storage bucket for query results
resource "google_storage_bucket" "query_results" {
  name          = "${var.project_name}-query-results-${var.gcp_project_id}"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}
