terraform {
  source = "${path_relative_from_include()}/../../../modules/lb"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}

dependency "sg" {
  config_path = "../00-sg"
}

inputs = {

  required_tags = {
    project   = "yozo"
    component = "lb"
  }

  tags = {}

  certificate_arn = "arn:aws:acm:eu-central-1:613725395756:certificate/2eb6a629-fade-44be-99d3-5b6224faac95"

  security_group_ids = [dependency.sg.outputs.id]

  subnets  = dependency.vpc.outputs.public_subnets
  internal = false
  listeners = [
    # {
    #   port     = 80
    #   protocol = "HTTP"
    # },
    {
      port     = 443
      protocol = "HTTPS"
    }
  ]
}


