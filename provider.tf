terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.4.0"
    }
    random = {
      source = "random"
    }
  }
}

provider "cloudflare" {
  email      = var.cloudflare_email
  account_id = var.cloudflare_account_id
  api_key    = var.cloudflare_api_key
}

provider "google" {
  project = var.gcp_project
}