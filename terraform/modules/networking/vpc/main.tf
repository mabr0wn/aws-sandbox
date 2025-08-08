terraform {
  # Require at least Terraform 1.5.0 and AWS provider v5.x
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider configuration
provider "aws" {
  region = var.region
}

# ----------- Data Sources -----------

# Get a list of all Availability Zones in the region
data "aws_availability_zones" "available" {}

# ----------- Local Variables -----------

locals {
  # Use the first 2 AZs in the selected AWS region
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # cidrsubnet(var.vpc_cidr, 8, i)
  # cidrsubnet splits a bigger CIDR into smaller ones.

  # Formula:

  # cidrsubnet(base_cidr, new_bits, net_num)
  # base_cidr → "10.10.0.0/16"

  # new_bits → 8 means we want to add 8 bits to the mask (/16 → /24), making smaller subnets.

  # net_num → Which subnet number to take (starting from 0).

  # Quick Rule of Thumb
    # /8 → first octet is network, everything else changes for subnets.
    # /16 → first two octets are network, third octet changes for subnets.
    # /24 → first three octets are network, fourth octet changes for subnets.

  # Example for public subnets:
    # i = 0 → cidrsubnet("10.10.0.0/16", 8, 0) → "10.10.0.0/24"
    # i = 1 → cidrsubnet("10.10.0.0/16", 8, 1) → "10.10.1.0/24"

  # Dynamically calculate CIDR blocks for public subnets
  public_subnet_cidrs  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i)]

  # Dynamically calculate CIDR blocks for private subnets
  private_subnet_cidrs = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i + 10)]

  # Base tags to apply to all resources
  base_tags = {
    owner       = var.owner
    environment = var.environment
    project     = var.project
  }
}

# ----------- VPC -----------

# Create the main VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.base_tags, var.tags, {
    Name = "${var.name}-vpc"
  })
}

# ----------- Internet Gateway -----------

# IGW for public subnet internet access
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.base_tags, { Name = "${var.name}-igw" })
}

# ----------- Public Subnets -----------

# Create a public subnet in each AZ
resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in local.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(each.key)]
  map_public_ip_on_launch = true # Assigns public IPs to EC2s in this subnet
  tags = merge(local.base_tags, {
    Name = format("%s-public-%s", var.name, local.azs[tonumber(each.key)])
    Tier = "public"
  })
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.base_tags, { Name = "${var.name}-public-rt" })
}

# Route all outbound traffic from public subnets to the IGW
resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ----------- Private Subnets -----------

# Create a private subnet in each AZ
resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in local.private_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = local.azs[tonumber(each.key)]
  tags = merge(local.base_tags, {
    Name = format("%s-private-%s", var.name, local.azs[tonumber(each.key)])
    Tier = "private"
  })
}

# Private route table for each private subnet
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = merge(local.base_tags, { Name = "${var.name}-private-rt-${each.key}" })
}

# ----------- NAT Gateway(s) -----------

# Create Elastic IP(s) for NAT Gateway(s)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(aws_subnet.public)) : 0
  domain = "vpc"
  tags   = merge(local.base_tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

# Create NAT Gateway(s) in the public subnet(s)
resource "aws_nat_gateway" "this" {
  count         = length(aws_eip.nat)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, var.single_nat_gateway ? 0 : count.index)
  tags          = merge(local.base_tags, { Name = "${var.name}-nat-${count.index}" })
  depends_on    = [aws_internet_gateway.this] # Ensure IGW exists first
}

# Route private subnet traffic through NAT Gateway
resource "aws_route" "private_nat" {
  for_each               = var.enable_nat_gateway ? aws_route_table.private : {}
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[tonumber(each.key)].id
}

# Associate each private subnet with its route table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
