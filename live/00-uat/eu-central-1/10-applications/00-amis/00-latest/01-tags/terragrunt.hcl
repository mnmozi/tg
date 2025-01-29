terraform {
  source = "github.com/mnmozi/tg//modules/ami-related/01-ami-tags"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "ami" {
  config_path = "../00-ami"
}

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).ami,
  {
    ami_name         = dependency.ami.outputs.name
    ebs_block_device = dependency.ami.outputs.ebs_block_device
  }
)
