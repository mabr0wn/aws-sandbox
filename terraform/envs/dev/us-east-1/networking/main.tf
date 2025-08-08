module "vpc" {
  source = "../../../../modules/networking/vpc"

  region             = var.region
  environment        = var.environment
  project            = var.project
  owner              = var.owner
  name               = var.name
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}

# Load variables
terraform {
  required_version = ">= 1.5.0"
}
