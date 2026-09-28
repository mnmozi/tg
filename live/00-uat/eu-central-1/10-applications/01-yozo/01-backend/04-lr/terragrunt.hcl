terraform {
  source = "${get_repo_root()}/modules//lr"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "lb" {
  config_path = "${get_parent_terragrunt_dir()}/10-applications/00-common/lbs/01-external-lb/01-lb"
}

dependency "tg" {
  config_path = "../03-tg"
}

inputs = {
  required_tags = {
    project   = "yozo"
    component = "application"
  }

  tags = {}

  listener_arn = dependency.lb.outputs.listeners["443"].arn
  priority     = 1

  action = {
    type = "forward"
  }
  target_group_arn = dependency.tg.outputs.arn

  # Only CloudFront (which adds this header) may reach the ALB directly.
  host_header = ["staging-yozo.cortechs-ai.com"]
  http_headers = [
    {
      name   = "Random-Salt"
      values = ["XKy5LLll87NNiRYurq"]
    }
  ]
}
