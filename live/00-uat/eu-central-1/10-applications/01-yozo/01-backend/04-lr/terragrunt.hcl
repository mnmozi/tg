
terraform {
  source = "${path_relative_from_include()}/../../../modules/lr"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${path_relative_from_include()}/00-infra/00-vpc"
}

dependency "lb" {
  config_path = "${path_relative_from_include()}/10-applications/00-common/lbs/01-external-lb/01-lb"
}

dependency "tg" {
  config_path = "../03-tg"
}

inputs = {
  required_tags = {
    project   = "yozo"
    component = "application"
  }
  tags         = {}
  listener_arn = dependency.lb.outputs.listeners["443"].arn

  priority = 1

  action = {
    type = "forward"
  }

  target_group_arn = dependency.tg.outputs.arn

  redirect_port = 443

  host_header = ["staging-yozo.cortechs-ai.com"]

  http_headers = [
    {
      name   = "Random-Salt"
      values = ["XKy5LLll87NNiRYurq"]
    }
  ]


  tags = {}

}


