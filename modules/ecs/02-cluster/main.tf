locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  cluster_identifier = (var.cluster_name == null || var.cluster_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.cluster_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.cluster_identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.0"

  cluster_name     = local.cluster_identifier
  cluster_settings = var.cluster_settings

  # Dynamically generate Fargate capacity providers
  fargate_capacity_providers = {
    for provider, config in var.fargate_capacity_providers :
    provider => {
      default_capacity_provider_strategy = var.default_capacity_provider_use_fargate ? {
        weight = config.weight,
        base   = lookup(config, "base", null) # Include base if provided, otherwise null
      } : {}
    }
  }
  autoscaling_capacity_providers = {
    for key, value in coalesce(var.autoscaling_capacity_providers, {}) :
    key => {
      auto_scaling_group_arn         = value.auto_scaling_group_arn
      managed_termination_protection = value.managed_termination_protection
      managed_scaling = {
        maximum_scaling_step_size = value.managed_scaling.maximum_scaling_step_size
        minimum_scaling_step_size = value.managed_scaling.minimum_scaling_step_size
        status                    = value.managed_scaling.status
        target_capacity           = value.managed_scaling.target_capacity
      }
      default_capacity_provider_strategy = value.use_default_capacity_provider ? {
        weight = value.default_capacity_provider_weight
      } : {}
    }
  }


  tags = local.tags
}
