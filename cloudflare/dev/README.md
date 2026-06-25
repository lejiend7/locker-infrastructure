# Cloudflare Dev

Terraform workspace for the `dev` environment DNS records.

## Apply

```bash
terraform init
terraform plan
terraform apply
```

## Credentials

Get from Cloudflare dashboard:
- **API Token**: dash.cloudflare.com → Profile → API Tokens → Create Token → "Edit zone DNS"
- **Zone ID**: dash.cloudflare.com → select `lejiend7.com` → right sidebar

Add to `terraform.tfvars`:

```hcl
cloudflare_api_token = "your-token"
cloudflare_zone_id   = "your-zone-id"
```
