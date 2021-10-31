/*
  Create a Linux Jumpbox on Google Cloud Platform and connect to Cloudflare, 
  using a Argo Tunnel. Cloudflare secure's connectivity to the Jumpbox and 
  creates a browser-based SSH terminal access. 
*/

# Create secret to be used in Argo Tunnel configuration
resource "random_id" "tunnel_secret" {
  byte_length = 35
}

# Create Argo Tunnel in Cloudflare
resource "cloudflare_argo_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.app_tunnel_name
  secret     = tostring(random_id.tunnel_secret.b64_std)
}

# Create CNAME record and use argo specific name
resource "cloudflare_record" "cname" {
  zone_id = var.cloudflare_zone_id
  name    = var.dns_record
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

# Create a application in Cloudflare Teams that will be used to authenticate to
resource "cloudflare_access_application" "jumpbox" {
  zone_id          = var.cloudflare_zone_id
  name             = var.app_tunnel_name
  domain           = var.dns_record
  type             = var.service_type
  session_duration = var.session_duration
}

# Cloudflare Team's policy for application created prior
resource "cloudflare_access_policy" "access_policy" {
  application_id = cloudflare_access_application.jumpbox.id
  zone_id        = var.cloudflare_zone_id
  name           = var.access_policy_name
  precedence     = "1"
  decision       = "allow"

  include {
    email_domain = [var.email_domain]
  }

  require {
    email_domain = [var.email_domain]
  }
}

# Create SSH short-lived certificate
resource "cloudflare_access_ca_certificate" "ssh_short_lived" {
  zone_id        = var.cloudflare_zone_id
  application_id = cloudflare_access_application.jumpbox.id
}

/* 
  - Create virtual machine on Google Cloud Platform
  - Pass in script to configure the Linux VM post start
*/

resource "google_compute_instance" "vm_instance" {

  zone = var.zone

  name         = var.server_name
  machine_type = var.server_type

  scheduling {
    preemptible       = var.pre_empt
    automatic_restart = false
  }

  labels = {
    owner = var.gcp_label
  }
  tags = [var.gcp_net_tag]

  boot_disk {
    initialize_params {
      image = var.server_image
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
      nat_ip       = ""
      network_tier = var.network_tier
    }
  }

  metadata_startup_script = templatefile(var.script_loc,
    {
      account   = var.cloudflare_account_id
      api_token = var.cloudflare_api_key
      cf_email  = var.cloudflare_email
      uuid      = cloudflare_access_application.jumpbox.id
      logo_url  = var.logo_url
      site_name = var.app_tunnel_name
      domain    = var.dns_record

      zone1       = var.dns_record
      tunnel_id   = "${cloudflare_argo_tunnel.auto_tunnel.id}"
      tunnel_name = var.app_tunnel_name
      secret      = tostring(random_id.tunnel_secret.b64_std)

      ssh_ca_cert = cloudflare_access_ca_certificate.ssh_short_lived.public_key
  })
}