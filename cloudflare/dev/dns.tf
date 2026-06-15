resource "cloudflare_record" "locker_static" {
  zone_id = var.cloudflare_zone_id
  name    = "locker"
  value   = var.cloudfront_domain
  type    = "CNAME"
  ttl     = 3600
  proxied = true
}

resource "cloudflare_record" "dev_smart_locker" {
  zone_id = var.cloudflare_zone_id
  name    = "dev-smart-locker"
  value   = var.smart_locker_backend_domain
  type    = "CNAME"
  ttl     = 3600
  proxied = true
}
