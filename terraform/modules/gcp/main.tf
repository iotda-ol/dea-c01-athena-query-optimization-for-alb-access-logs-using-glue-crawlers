# GCP Module for Load Balancer Logs Analysis
# Provides: Cloud Storage, BigQuery, Cloud Functions infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    project     = "dea-c01-log-optimization"
    environment = var.environment
    managed_by  = "terraform"
    module      = "gcp"
  }
}
