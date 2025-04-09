terraform {
  source = "/Users/mostafa.hamed/mycode/personal/tg/modules/sg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    environment = include.root.inputs.environment
    project     = "yozo"
    component   = "db"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})

  # ingress_sg_ids = [
  #   {
  #     security_groups = [dependency.app_sg.outputs.id]
  #     description     = "allow port 5432"
  #     from_port       = 5432
  #     to_port         = 5432
  #     protocol        = "tcp"
  #   }
  # ]

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
