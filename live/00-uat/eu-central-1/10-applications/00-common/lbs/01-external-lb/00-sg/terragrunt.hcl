terraform {
  source = "${get_repo_root()}/modules//sg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}


inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    project   = "yozo"
    component = "lb"
  }

  tags = merge(include.root.inputs.tags, {})

  ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  ]

  ingress_sg = {}

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
