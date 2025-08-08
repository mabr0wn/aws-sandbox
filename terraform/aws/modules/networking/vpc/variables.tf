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
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
}
