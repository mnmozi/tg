terraform {
  source = "${get_repo_root()}/modules//ec2"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

dependency "sg" {
  config_path = "../00-sg"
}

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).ec2,
  {
    sg        = [dependency.sg.outputs.id]
    subnet_id = dependency.vpc.outputs.public_subnets[0]
  }
)
