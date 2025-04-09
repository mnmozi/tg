variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "ecs_service_target" {
  description = "ECS Auto Scaling Target Configuration"
  type = object({
    max_capacity       = number
    min_capacity       = number
    resource_id        = string
    scalable_dimension = string
    service_namespace  = string
  })
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "scaling_schedules" {
  description = "List of scheduled scaling actions"
  type = list(object({
    name     = string
    schedule = string
    timezone = string
    min_cap  = number
    max_cap  = number
  }))
}

variable "scaling_policies" {
  description = "Map of scaling policies for ECS"
  type = map(object({
    predefined_metric_type = string
    target_value           = number
    scale_in_cooldown      = number
    scale_out_cooldown     = number
  }))
}
