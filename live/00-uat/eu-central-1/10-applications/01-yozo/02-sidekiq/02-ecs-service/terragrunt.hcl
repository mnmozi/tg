terraform {
  source = "${get_repo_root()}/modules//ecs/03-service"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

dependency "cluster" {
  config_path = "${get_parent_terragrunt_dir()}/10-applications/00-common/ecs-clusters/yozo-applications"
}

dependency "sg" {
  config_path = "../00-sg"
}

dependency "task_definition" {
  config_path = "../01-task-definition"
}

inputs = {
  cluster_name                      = dependency.cluster.outputs.cluster_name
  task_definition                   = dependency.task_definition.outputs.family
  desired_count                     = 1
  health_check_grace_period_seconds = 30
  enable_execute_command            = true

  required_tags = {
    project   = "yozo"
    component = "sidekiq"
  }

  tags = {}

  capacity_providers = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 0
    },
    {
      base              = 1
      capacity_provider = "FARGATE"
      weight            = 100
    }
  ]

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  subnets          = dependency.vpc.outputs.public_subnets
  sg               = [dependency.sg.outputs.id]
  assign_public_ip = true

  wait_for_steady_state = false
}
