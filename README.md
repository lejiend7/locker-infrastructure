# Locker Infrastructure - Terraform

Multi-cloud, multi-environment infrastructure as code for Locker project.

## Architecture Overview

### Current Setup (Terraform)
Basic Terraform structure for each provider and environment. Simple, straightforward configuration for current infrastructure complexity.

### Future Evolution (Terragrunt + Terraform Modules)
As the project grows in complexity and we need to manage multiple environments with reusable components, we will introduce:
- **Terragrunt**: For managing Terraform configurations across multiple environments
- **Terraform Modules**: For reusable, composable infrastructure components
- **Remote State Management**: Centralized state backend with locking
- **Automated Workflows**: CI/CD pipeline for infrastructure changes

## Directory Structure

```
locker-infrastructure/
├── cloudflare/       # DNS & HTTPS proxy
│   └── dev/
├── aws/              # Compute & storage
│   └── dev/
├── README.md
└── .gitignore
```

## Providers & Responsibilities

### Cloudflare
- **DNS**: Points domain to S3 bucket
- **HTTPS/SSL**: Manages SSL/TLS certificates via Cloudflare proxy
- **DDoS Protection**: Built-in security features

### AWS
- **Compute**: EC2 instances for application servers
- **Storage**: S3 bucket for static website assets

## Quick Start

### Cloudflare (DNS & HTTPS)
```bash
cd cloudflare/dev
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

### AWS (EC2 & S3)
```bash
cd aws/dev
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

## Environments

- **dev**: Development environment
- **staging**: Staging environment (coming soon)
- **production**: Production environment (coming soon)

Each environment maintains its own state and variables.

## Documentation

- [Cloudflare Setup](./cloudflare/README.md)
- [AWS Setup](./aws/README.md)
