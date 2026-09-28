terraform {
  source = "${get_repo_root()}/modules//sg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}
dependency "lb_sg" {
  config_path = "${get_parent_terragrunt_dir()}/10-applications/00-common/lbs/01-external-lb/00-sg"
}
dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    project   = "yozo"
    component = "application"
  }

  tags = merge(include.root.inputs.tags, {})

  ingress_sg_ids = [
    {
      security_groups = [dependency.lb_sg.outputs.id]
      description     = "allow port 80 for lb"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
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
