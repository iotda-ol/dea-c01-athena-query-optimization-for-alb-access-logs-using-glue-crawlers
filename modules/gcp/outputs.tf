output "lb_logs_bucket_name" {
  description = "Name of the Cloud Storage bucket for LB logs"
  value       = google_storage_bucket.lb_logs.name
}

output "query_results_bucket_name" {
  description = "Name of the Cloud Storage bucket for query results"
  value       = google_storage_bucket.query_results.name
}

output "bigquery_dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = google_bigquery_dataset.lb_logs.dataset_id
}

output "bigquery_table_id" {
  description = "ID of the BigQuery table"
  value       = google_bigquery_table.lb_access_logs.table_id
}

output "bigquery_table_full_id" {
  description = "Full ID of the BigQuery table (project:dataset.table)"
  value       = "${var.gcp_project_id}:${google_bigquery_dataset.lb_logs.dataset_id}.${google_bigquery_table.lb_access_logs.table_id}"
}
