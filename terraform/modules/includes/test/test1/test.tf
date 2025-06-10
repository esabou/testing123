# Storage bucket backend for Terraform state (terraform config block doesn't support variables)
terraform {
  backend "gcs" {
    bucket = "prod-paja-320519-terraform"
    prefix = "pajax-state"
  }
}

module "labels" {
  source = "../../modules/labels"
}

locals {
  project_id     = "prod-paja-320519"
  project_number = 983435904498
  region         = "europe-north1"
  zone           = "europe-north1-a"
  env            = "prod"
  labels         = merge(module.labels.project_labels, {environment-name = "prod"}) # sandbox, tools / shared, dev, stg, prod, vt[01-99]
}

module "required_versions" {
  source = "../../modules/versions"
}

provider "google" {
  project        = local.project_id
  region         = local.region
  zone           = local.zone
  default_labels = local.labels
}

provider "google-beta" {
  project        = local.project_id
  region         = local.region
  zone           = local.zone
  default_labels = local.labels
}

# Service accounts
module "service-accounts" {
  source = "../../modules/service-accounts"
  project_id      = local.project_id
  project_number  = local.project_number
  env             = local.env
}

# Project storage bucket objects
module "storage-buckets" {
  source = "../../modules/storage-buckets"

  project_id          = local.project_id
  region              = local.region
  startup_bucket_name = "${local.project_id}-startup"
  pajax_profile_file   = "pajax_profile-${local.env}"
  crontab_file        = "crontab-${local.env}.txt"
  env                 = local.env
}
