output "CNAME" {
  value = ["${cloudflare_record.cname.*.name}"]
}
