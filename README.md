# AWS Sandbox – Terraform Infrastructure

## Overview
The **AWS Sandbox** is a Terraform-based infrastructure project for experimenting, testing, and deploying AWS resources in a modular and reusable way.  
It’s structured to separate reusable building blocks (**modules**) from deployable configurations (**stacks**) and environment-specific overlays (**envs**).

This layout is designed for:
- **Scalability** – Easily add new AWS services or environments
- **Reusability** – Write once, use across multiple stacks
- **Maintainability** – Logical separation of concerns
- **Collaboration** – Clear boundaries for team members

---

## Folder Structure

```

aws-sandbox/
└─ terraform/
└─ aws/
├─ modules/             # Reusable building blocks
│  ├─ networking/       # VPC, subnets, route tables, gateways, etc.
│  ├─ edge/              # Load balancers, CDN, DNS, API Gateway
│  ├─ security/          # IAM, KMS, Secrets Manager, GuardDuty
│  ├─ compute/           # EC2, ASG, ECS, EKS, Lambda
│  ├─ storage/           # S3, EFS, Backup
│  ├─ databases/         # RDS, Aurora, DynamoDB, ElastiCache
│  ├─ observability/     # CloudWatch, logs, alarms, EventBridge, SNS/SQS
│  ├─ cicd/              # CodePipeline, CodeBuild, CodeDeploy
│  ├─ data-analytics/    # Glue, Athena, EMR, Kinesis
│  └─ management/        # Organizations, Identity Center, Config, CloudTrail
│
├─ stacks/               # Deployable compositions that call modules
│  ├─ create-resource-group/
│  ├─ create-vpc/
│  ├─ network-foundation/
│  ├─ security-foundation/
│  ├─ shared-services/
│  ├─ app-ecs/
│  ├─ app-eks/
│  ├─ serverless-app/
│  └─ data-platform/
│
├─ envs/                 # Environment-specific configurations
│  ├─ dev/               # Development
│  ├─ qa/                # QA / Staging
│  └─ prod/              # Production
│
├─ globals/              # Shared provider/backend/version settings
└─ scripts/              # Helper scripts for plan/apply automation

````

---

## How to Use

1. **Clone the repository**
   ```bash
   git clone git@github.com:YOUR_USERNAME/aws-sandbox.git
   cd aws-sandbox/terraform/aws


2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Select a stack to deploy**

   ```bash
   cd stacks/create-resource-group
   terraform plan -var-file="../../envs/dev/us-east-1/terraform.tfvars"
   terraform apply
   ```

4. **Add new modules or stacks**

   * Add new reusable logic in `modules/`
   * Reference those modules inside `stacks/`

---

## Notes

* **Modules** are AWS resource blueprints.
* **Stacks** are deployable configurations built from modules.
* **Envs** customize stacks for dev, QA, and production.
* **Globals** will later store shared provider configs, Terraform backend, and version pins.

---

## Future Enhancements

* Add backend state configuration to `globals/`
* Create CI/CD workflows for automated Terraform validation
* Add example `.tf` files in each module for quick start

