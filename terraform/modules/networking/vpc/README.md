# vpc module

Creates a VPC with:
- public + private subnets spread across AZs,
- IGW,
- optional NAT gateway(s) (1 per AZ or a single shared NAT),
- proper route tables and associations.

### Inputs
- `name` – resource prefix
- `vpc_cidr` – VPC CIDR (e.g., 10.0.0.0/16)
- `azs` – list of AZs (e.g., ["us-east-1a","us-east-1b"])
- `public_subnet_cidrs` – list CIDRs aligned with `azs`
- `private_subnet_cidrs` – list CIDRs aligned with `azs`
- `enable_nat_gateway` – bool
- `single_nat_gateway` – bool (cheaper vs HA)
- `tags` – map of tags

### Outputs
- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `igw_id`, `nat_gateway_ids`
