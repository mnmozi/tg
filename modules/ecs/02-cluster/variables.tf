variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Optional custom name for the ECS service"
  type        = string
  default     = null
}

variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "The required tags that must be included for all resources."
}

variable "tags" {
  description = "Additional tags to merge with required tags"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the service (optional)"
  type        = string
  default     = null
}

variable "cluster_settings" {
  description = "List of cluster settings for the ECS cluster"
  type        = list(map(any))
  default     = []
}

variable "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity providers"
  type = map(object({
    auto_scaling_group_arn         = string
    managed_termination_protection = string
    managed_scaling = object({
      maximum_scaling_step_size = number
      minimum_scaling_step_size = number
      status                    = string
      target_capacity           = number
    })
    use_default_capacity_provider    = bool
    default_capacity_provider_weight = number
  }))
  default = null
}
variable "default_capacity_provider_use_fargate" {
  description = "Boolean to enable default capacity provider strategies for Fargate"
  type        = bool
  default     = false
}

variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity providers and their configurations"
  type = map(object({
    weight = number
    base   = optional(number)
  }))
  default = {}
}
