variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Tags applied to the Resource Group objects themselves"
  type        = map(string)
  default     = { managed-by = "terraform" }
}

# Simple driver: just list which envs you want groups for
variable "environments" {
  description = "Set of environments to generate groups for"
  type        = set(string)
  default     = ["dev", "qa", "prod"]
}

# Global tag key; most teams use env/environment
variable "tag_key" {
  description = "Tag key used in the TAG_FILTERS_1_0 query"
  type        = string
  default     = "env"
}

# Auto-name groups like rg-dev-tagged, rg-qa-tagged, etc.
variable "group_name_prefix" {
  description = "Prefix used for generated group names"
  type        = string
  default     = "rg"
}

# Optional per-env overrides
variable "per_env_overrides" {
  description = <<DESC
Optional per-environment overrides. Any field can be provided:
  name                  : string
  tag_value             : string (defaults to the env name)
  description           : string
  resource_type_filters : list(string)
  tags                  : map(string)
Example:
{
  prod = {
    name                  = "rg-prod-critical"
    resource_type_filters = ["AWS::EC2::Instance", "AWS::RDS::DBInstance"]
    tags                  = { tier = "critical" }
  }
}
DESC
  type = map(object({
    name                  = optional(string)
    tag_value             = optional(string)
    description           = optional(string)
    resource_type_filters = optional(list(string))
    tags                  = optional(map(string))
  }))
  default = {}
}

# Optional extra groups not tied to env list
variable "extra_groups" {
  description = <<DESC
Ad-hoc groups to add in addition to the generated env groups.
Keys are handles, each value:
  name, tag_key, tag_value, description?, resource_type_filters?, tags?
DESC
  type = map(object({
    name                  = string
    tag_key               = string
    tag_value             = string
    description           = optional(string)
    resource_type_filters = optional(list(string), ["AWS::AllSupported"])
    tags                  = optional(map(string), {})
  }))
  default = {}
}
