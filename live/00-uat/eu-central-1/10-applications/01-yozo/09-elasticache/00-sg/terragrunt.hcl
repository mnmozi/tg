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
dependency "app_sg" {
  config_path = "../../01-backend/00-sg"
}
dependency "sidekiq_sg" {
  config_path = "../../02-sidekiq/00-sg"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    environment = include.root.inputs.environment
    project     = "yozo"
    component   = "elasticache"
  }

  tags = merge(include.root.inputs.tags, {})

  ingress_sg_ids = [
    {
      security_groups = [dependency.app_sg.outputs.id, dependency.sidekiq_sg.outputs.id]
      description     = "allow port 6379"
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
    }
  ]

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
