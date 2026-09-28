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

  asg_capacity_providers = coalesce(var.autoscaling_capacity_providers, {})

  # Default strategy: Fargate providers (when enabled) plus any ASG provider
  # that opted in to the default strategy.
  default_capacity_provider_strategy = merge(
    var.default_capacity_provider_use_fargate ? {
      for name, config in var.fargate_capacity_providers :
      name => { weight = config.weight, base = config.base }
    } : {},
    {
      for name, config in local.asg_capacity_providers :
      name => { weight = config.default_capacity_provider_weight }
      if config.use_default_capacity_provider
    }
  )
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.6.1"

  cluster_name    = local.cluster_identifier
  cluster_setting = [for s in var.cluster_settings : { name = s.name, value = s.value }]

  # v7 no longer infers FARGATE/FARGATE_SPOT from the strategy; list them explicitly.
  cluster_capacity_providers         = keys(var.fargate_capacity_providers)
  default_capacity_provider_strategy = length(local.default_capacity_provider_strategy) > 0 ? local.default_capacity_provider_strategy : null

  capacity_providers = {
    for name, config in local.asg_capacity_providers :
    name => {
      auto_scaling_group_provider = {
        auto_scaling_group_arn         = config.auto_scaling_group_arn
        managed_termination_protection = config.managed_termination_protection
        managed_scaling = {
          maximum_scaling_step_size = config.managed_scaling.maximum_scaling_step_size
          minimum_scaling_step_size = config.managed_scaling.minimum_scaling_step_size
          status                    = config.managed_scaling.status
          target_capacity           = config.managed_scaling.target_capacity
        }
      }
    }
  }

  tags = local.tags
}
