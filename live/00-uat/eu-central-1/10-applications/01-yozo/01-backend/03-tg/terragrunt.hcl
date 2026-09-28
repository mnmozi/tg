
terraform {
  source = "${get_repo_root()}/modules//tg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

inputs = {

  required_tags = {
    project   = "yozo"
    component = "application"
  }
  tags = {}

  # Target Group Configuration
  target_port = 80
  protocol    = "HTTP"
  vpc_id      = dependency.vpc.outputs.vpc_id
  # target_type = "instance"
  # Health Check Configuration
  health_check_path     = "/api/health_check"
  health_check_protocol = "HTTP"
  health_check_interval = 30
  unhealthy_threshold   = 3
  healthy_threshold     = 2
  health_check_matcher  = 200
}


