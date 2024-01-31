variable "credentials" {
  description = "My Credentials"
  default     = "~/keys/terraform/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "krause-zoomcamp-2024"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default = "us-east1-b"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "krause-zoomcamp-2024-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}