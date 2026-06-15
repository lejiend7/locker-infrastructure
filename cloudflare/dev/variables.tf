variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for lejiend7.com"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Primary domain"
  type        = string
  default     = "lejiend7.com"
}

variable "cloudfront_domain" {
  description = "CloudFront domain for static site"
  type        = string
  default     = "de7bsautsq6ez.cloudfront.net"
}

variable "smart_locker_backend_domain" {
  description = "Backend domain for dev-smart-locker"
  type        = string
  default     = "xxx.bbb.com"
}
