terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  project = "krause-zoomcamp-2024"
  region  = "us-east1-b"
}



resource "google_storage_bucket" "data-lake-bucket" {
  name          = "krause-zoomcamp-2024-terra-bucket"
  location      = "US"

  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}
