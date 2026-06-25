# Cloudflare Infrastructure

Manages DNS records for `lejiend7.com` via Terraform. State is stored separately from the AWS workspace.

## DNS Records

| Record | Type | Target | Proxied |
|---|---|---|---|
| `dev-api-smart-locker.lejiend7.com` | CNAME | API Gateway regional domain | Yes |
| `dev-smart-locker.lejiend7.com` | CNAME | CloudFront distribution | Yes |
| `dev-vpn.lejiend7.com` | A | VPN EC2 public IP | No |

## Setup

```bash
cd dev
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description |
|---|---|
| `cloudflare_api_token` | Cloudflare API token (Edit zone DNS permission) |
| `cloudflare_zone_id` | Zone ID for lejiend7.com |
| `api_gateway_domain` | API Gateway regional domain — get from `cd aws/dev && terraform output api_gateway_regional_domain_name` |
| `cloudfront_domain` | CloudFront domain — get from `cd aws/dev && terraform output cloudfront_domain_name` |
| `vpn_ip` | VPN EC2 public IP — get from `cd aws/dev && terraform output vpn_public_ip` |

## Updating cross-workspace values

Since AWS and Cloudflare states are separate, copy values manually after an AWS apply:

```bash
cd aws/dev
terraform output api_gateway_regional_domain_name  # → api_gateway_domain
terraform output cloudfront_domain_name            # → cloudfront_domain
terraform output vpn_public_ip                     # → vpn_ip
```

Paste into `cloudflare/dev/terraform.tfvars`, then run `terraform apply`.
