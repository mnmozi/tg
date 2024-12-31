terraform {
  source = "../../../../../../../modules/ecs/02-cluster"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {

  required_tags = {
    project   = "yozo"
    component = "cluster"
  }
  tags = {}

  # Cluster settings
  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enhanced"
    }
  ]

  # Fargate capacity providers
  default_capacity_provider_use_fargate = true
  fargate_capacity_providers = {
    FARGATE = {
      weight = 0
    }
    FARGATE_SPOT = {
      weight = 100
    }
  }

  # Autoscaling capacity providers
  # autoscaling_capacity_providers = {
  #   "t3-small-spot" = {
  #     auto_scaling_group_arn         = "arn:aws:autoscaling:region:account-id:autoScalingGroupName"
  #     managed_termination_protection = "ENABLED"
  #     managed_scaling = {
  #       maximum_scaling_step_size = 1
  #       minimum_scaling_step_size = 1
  #       status                    = "ENABLED"
  #       target_capacity           = 100
  #     }
  #     use_default_capacity_provider    = true
  #     default_capacity_provider_weight = 50
  #   }
  #   "t3-medium-spot" = {
  #     auto_scaling_group_arn         = "arn:aws:autoscaling:region:account-id:autoScalingGroupName2"
  #     managed_termination_protection = "ENABLED"
  #     managed_scaling = {
  #       maximum_scaling_step_size = 2
  #       minimum_scaling_step_size = 2
  #       status                    = "ENABLED"
  #       target_capacity           = 100
  #     }
  #     use_default_capacity_provider    = false
  #     default_capacity_provider_weight = 0
  #   }
  # }
}
