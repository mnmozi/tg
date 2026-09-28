terraform {
  source = "${get_repo_root()}/modules//ami-related/00-ami"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# dependency "ec2" {
#   config_path = "../../../02-ec2/01-ec2"
# }

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).ami,
  {
    instance_id = "i-09112688f94f51e9b" # or dependency.ec2.outputs.id once the ec2 unit is applied
  }
)
