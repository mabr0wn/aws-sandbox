variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, prod, etc.)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "owner" {
  type        = string
  description = "Owner/team name"
}

variable "name" {
  type        = string
  description = "Base name for resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to enable a NAT Gateway for private subnet internet access"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "If true, use a single NAT Gateway instead of one per AZ"
}

variable "azs" {
  type        = list(string)
  default     = null
  description = "List of AZs to use. If null, the first 2 AZs are used."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = null
  description = "Explicit public subnet CIDRs. If null, compute from vpc_cidr."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = null
  description = "Explicit private subnet CIDRs. If null, compute from vpc_cidr."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags to merge with base tags."
}
