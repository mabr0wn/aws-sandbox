variable "region" {
  description = "AWS region"
  type        = string
}

variable "name" {
  description = "Prefix for naming"
  type        = string
}

variable "vpc_cidr"              { type = string }
variable "azs"                   { type = list(string) }
variable "public_subnet_cidrs"   { type = list(string) }
variable "private_subnet_cidrs"  { type = list(string) }

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "default_tags" {
  description = "Tags applied to all resources via provider + module"
  type        = map(string)
  default     = {}
}
