terraform {
  source = "${get_repo_root()}/modules//ecs/04-autoscaling"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "service" {
  config_path = "../02-ecs-service"
}

inputs = {
  ecs_service_target = {
    max_capacity       = 5
    min_capacity       = 3
    resource_id        = "service/${dependency.service.outputs.cluster_name}/${dependency.service.outputs.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
  }

  service_name = dependency.service.outputs.name

  scaling_schedules = [
    {
      name     = "business-hours"
      schedule = "cron(0 13 * * ? *)"
      timezone = "Asia/Dubai"
      min_cap  = 3
      max_cap  = 5
    },
    {
      name     = "off-hours"
      schedule = "cron(0 0 * * ? *)"
      timezone = "Asia/Dubai"
      min_cap  = 2
      max_cap  = 5
    }
  ]

  scaling_policies = {
    cpu = {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
      target_value           = 80
      scale_in_cooldown      = 300
      scale_out_cooldown     = 300
    }
  }
}
