terraform {
  source = "github.com/mnmozi/tg//modules/ec2"
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

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).ec2,
  {
    sg        = [dependency.sg.outputs.id]
    subnet_id = dependency.vpc.outputs.public_subnets[0]
  }
)
