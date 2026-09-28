terraform {
  source = "${get_repo_root()}/modules//asg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

dependency "lt" {
  config_path = "../01-lt"
}

inputs = {
  required_tags = {
    project   = "yozo"
    component = "ecs-m6i-large"
  }

  tags = {}

  max_size                  = 5
  min_size                  = 0
  desired_capacity          = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = false
  desired_capacity_type     = "units"
  capacity_rebalance        = true
  vpc_zone_identifier       = dependency.vpc.outputs.private_subnets
  instance_type             = "m6i.large"

  launch_template = {
    id      = dependency.lt.outputs.id
    version = "$Latest"
  }
}
