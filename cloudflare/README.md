# Cloudflare Infrastructure

Manages DNS and HTTPS/SSL certificates for Locker project.

## Features
- **DNS Management**: Configure DNS records pointing to AWS CloudFront
- **HTTPS/SSL**: Automatic SSL/TLS certificates via Cloudflare proxy
- **DDoS Protection**: Built-in security from Cloudflare

## Setup

```bash
cd dev
cp terraform.tfvars.example terraform.tfvars
# Edit with your Cloudflare API token and zone ID
terraform init && terraform apply
```

## Configuration

Edit `dev/terraform.tfvars`:
- `cloudflare_api_token`: Your Cloudflare API token
- `cloudflare_zone_id`: Your domain's zone ID
- `domain`: Your domain name

## Adding DNS Records

Edit `dev/dns.tf` and add records pointing to CloudFront:

```hcl
resource "cloudflare_record" "website" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = "d123abc.cloudfront.net"
  type    = "CNAME"
  ttl     = 3600
  proxied = true  # Enable Cloudflare proxy for HTTPS
}
```

See [Cloudflare Terraform Provider Docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs) for more record types.
