# Locker Infrastructure - Terraform

Multi-environment Terraform configuration for Locker infrastructure management.

## Directory Structure

```
locker-infrastructure/
├── dev/              # Development environment
├── staging/          # Staging environment (coming soon)
├── production/       # Production environment (coming soon)
└── .gitignore
```

## Setup

1. Navigate to your environment:
   ```bash
   cd dev
   ```

2. Copy example tfvars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Update `terraform.tfvars` with your Cloudflare credentials

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Environments

- **dev**: Development environment for testing
- **staging**: Staging environment (to be configured)
- **production**: Production environment (to be configured)

Each environment has its own isolated state and variables.
