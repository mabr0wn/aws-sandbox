variable "region" {}
variable "environment" {}
variable "project" {}
variable "owner" {}
variable "name" {}
variable "vpc_cidr" {}
variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "tags" {
  type = map(string)
  default = {}
}
