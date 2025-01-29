terraform {
  source = "github.com/mnmozi/tg//modules/sg"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}

inputs = merge(
  jsondecode(file("../inputs.json")).sg,
  {
    vpc_id = dependency.vpc.outputs.vpc_id
  }
)
