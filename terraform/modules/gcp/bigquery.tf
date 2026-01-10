# BigQuery dataset for log analysis
resource "google_bigquery_dataset" "lb_logs" {
  dataset_id                  = "${replace(var.project_name, "-", "_")}_logs"
  friendly_name               = "Load Balancer Logs Dataset"
  description                 = "Dataset for load balancer log analysis with partitioning"
  location                    = var.dataset_location
  default_table_expiration_ms = var.log_retention_days * 24 * 60 * 60 * 1000

  labels = {
    environment = var.environment
    module      = "gcp"
  }
}

# BigQuery external table for Cloud Storage logs
resource "google_bigquery_table" "lb_access_logs" {
  dataset_id = google_bigquery_dataset.lb_logs.dataset_id
  table_id   = "lb_access_logs"

  deletion_protection = false

  schema = jsonencode([
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "client_ip"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "client_port"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "backend_ip"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "backend_port"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "request_processing_time"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "backend_processing_time"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "response_processing_time"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "lb_status_code"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "backend_status_code"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "received_bytes"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "sent_bytes"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "request_method"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "request_url"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "request_protocol"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "user_agent"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  clustering = ["client_ip", "lb_status_code"]
}
