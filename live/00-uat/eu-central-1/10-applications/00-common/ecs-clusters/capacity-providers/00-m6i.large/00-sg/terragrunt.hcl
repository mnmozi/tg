terraform {
  source = "${path_relative_from_include()}/../../../modules/sg"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  required_tags = {
    project   = "malaeb"
    component = "cluster"
  }

  tags = merge(include.root.inputs.tags, {})

  ingress_rules = []

  ingress_sg = {
    # staging-yozo-application  = {
    #   description = "Allow traffic from Security Group sg1"
    #   from_port   = 5432
    #   to_port     = 5432
    #   protocol    = "tcp"
    # }
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
