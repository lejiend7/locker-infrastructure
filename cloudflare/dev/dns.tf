resource "cloudflare_record" "dev_smart_locker_frontend" {
  zone_id = var.cloudflare_zone_id
  name    = "dev-smart-locker"
  content = var.cloudfront_domain
  type    = "CNAME"
  ttl     = 0
  proxied = false
}

resource "cloudflare_record" "dev_api_smart_locker" {
  zone_id = var.cloudflare_zone_id
  name    = "dev-api-smart-locker"
  content = var.ec2_ip
  type    = "A"
  ttl     = 0
  proxied = false
}
