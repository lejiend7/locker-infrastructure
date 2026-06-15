output "zone_id" {
  description = "Cloudflare Zone ID"
  value       = var.cloudflare_zone_id
  sensitive   = true
}

output "domain" {
  description = "Primary domain"
  value       = var.domain
}

output "locker_fqdn" {
  description = "Locker static site FQDN"
  value       = "locker.${var.domain}"
}

output "dev_smart_locker_fqdn" {
  description = "Dev smart locker backend FQDN"
  value       = "dev-smart-locker.${var.domain}"
}
