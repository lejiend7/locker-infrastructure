# Cloudflare DNS - Terraform

Manages DNS records for lejiend7.com domain.

## Setup

### 1. Get Cloudflare Credentials

**API Token:**
- Go to: https://dash.cloudflare.com/profile/api-tokens
- Click "Create Token"
- Use template: "Edit zone DNS"
- Copy token

**Zone ID:**
- Go to: https://dash.cloudflare.com
- Select domain: lejiend7.com
- Right sidebar shows "Zone ID"
- Copy it

### 2. Add to terraform.tfvars

```bash
vim terraform.tfvars
```

Replace values:
```hcl
cloudflare_api_token = "paste-your-token-here"
cloudflare_zone_id   = "paste-your-zone-id-here"
```

### 3. Apply

```bash
terraform init
terraform plan
terraform apply
```

## DNS Records Created

- `locker.lejiend7.com` → CloudFront (de7bsautsq6ez.cloudfront.net)
- `dev-smart-locker.lejiend7.com` → Backend (xxx.bbb.com)

Both use Cloudflare proxy for HTTPS.

## Update Backend Domain

Edit `variables.tf` default value:
```hcl
variable "smart_locker_backend_domain" {
  default = "your-new-domain.com"
}
```

Then: `terraform apply`
