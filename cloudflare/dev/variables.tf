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

variable "api_gateway_domain" {
  description = "API Gateway regional domain name — copy from: cd aws/dev && terraform output api_gateway_regional_domain_name"
  type        = string
  default     = ""
}

variable "vpn_ip" {
  description = "VPN server IP"
  type        = string
  default     = ""
}