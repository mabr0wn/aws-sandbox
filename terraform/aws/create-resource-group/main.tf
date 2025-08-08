terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.region
}

# Build a normalized map of env-based groups
locals {
  generated_env_groups = {
    for env in var.environments :
    env => {
      name                  = coalesce(try(var.per_env_overrides[env].name, null), "${var.group_name_prefix}-${env}-tagged")
      tag_key               = var.tag_key
      tag_value             = coalesce(try(var.per_env_overrides[env].tag_value, null), env)
      description           = try(var.per_env_overrides[env].description, null)
      resource_type_filters = try(var.per_env_overrides[env].resource_type_filters, ["AWS::AllSupported"])
      tags                  = try(var.per_env_overrides[env].tags, {})
    }
  }

  # Final merge: env-generated groups + any extra ad-hoc groups you define
  final_groups = merge(local.generated_env_groups, var.extra_groups)
}

resource "aws_resourcegroups_group" "group" {
  for_each = local.final_groups

  name        = each.value.name
  description = lookup(each.value, "description", null)

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = lookup(each.value, "resource_type_filters", ["AWS::AllSupported"])
      TagFilters = [
        {
          Key    = each.value.tag_key
          Values = [each.value.tag_value]
        }
      ]
    })
    type = "TAG_FILTERS_1_0"
  }

  tags = merge(var.default_tags, lookup(each.value, "tags", {}))
}

output "aws_group_arns" {
  value = { for k, g in aws_resourcegroups_group.group : k => g.arn }
}
