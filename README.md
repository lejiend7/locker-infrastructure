# Locker Infrastructure - Terraform

Multi-cloud, multi-environment infrastructure as code for Locker project.

## Directory Structure

```
locker-infrastructure/
├── cloudflare/       # Cloudflare DNS management
│   └── dev/
├── aws/              # AWS resources (EC2, etc.)
│   └── dev/
├── README.md
└── .gitignore
```

## Quick Start

### Cloudflare (DNS)
```bash
cd cloudflare/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Cloudflare API token and zone ID
terraform init
terraform plan
terraform apply
```

### AWS (EC2)
```bash
cd aws/dev
cp terraform.tfvars.example terraform.tfvars
# Set AWS credentials
terraform init
terraform plan
terraform apply
```

## Environments

Each provider (Cloudflare, AWS) has:
- **dev**: Development environment
- **staging**: Staging environment (coming soon)
- **production**: Production environment (coming soon)

Each environment maintains its own state and variables.

## Documentation

- [Cloudflare Setup](./cloudflare/README.md)
- [AWS Setup](./aws/README.md)
