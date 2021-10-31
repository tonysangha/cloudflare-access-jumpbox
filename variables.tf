# Cloudflare Variables
variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Cloudflare email user"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  sensitive   = true
}

variable "app_tunnel_name" {
  description = "Name used across Argo Tunnel, and Access Application"
  type        = string
}

variable "dns_record" {
  type    = string
  default = ""
}

variable "service_type" {
  type    = string
  default = ""
}
variable "session_duration" {
  type    = string
  default = "1h"
}
variable "access_policy_name" {
  type    = string
  default = ""
}

variable "email_domain" {
  type    = string
  default = ""
}

variable "logo_url" {
  type    = string
  default = ""
}

# GCP server variables

variable "gcp_project" {
  description = "gcp project id"
  type        = string
}

variable "zone" {
  description = "GCP Region/Zone"
  type        = string
}

variable "gcp_label" {
  description = "Label objects created in GCP with:"
  type        = string
}
variable "server_name" {
  type = string
}

variable "server_image" {
  type = string
}

variable "server_type" {
  type = string
}
variable "network_tier" {
  type = string
}

variable "script_loc" {
  description = "configuration script"
  type        = string
}
variable "gcp_net_tag" {
  description = "Network Tag"
  type        = string
}

variable "pre_empt" {
  description = "Pre-Empt VM"
  type        = string
}