terraform {
  source = "${path_relative_from_include()}/../../../modules/sg"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    project   = "yozo"
    component = "sidekiq"
  }

  tags = merge(include.root.inputs.tags, {})

  ingress_rules = [
  ]

  ingress_sg = {
  }

  egress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
    }
  ]

  egress_sg = {}
}
