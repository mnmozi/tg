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

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).sg,
  {
    vpc_id = dependency.vpc.outputs.vpc_id
  }
)
