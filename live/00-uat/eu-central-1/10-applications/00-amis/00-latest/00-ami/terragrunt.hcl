terraform {
  source = "github.com/mnmozi/tg//modules/ami-related/00-ami"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

# dependency "ec2" {
#   config_path = "../../../02-ec2/01-ec2"
# }

inputs = merge(
  jsondecode(file("${get_terragrunt_dir()}/../inputs.json")).ami,
  {
    instance_id = "i-09112688f94f51e9b" //dependency.ec2.outpus.ec2.id
  }
)
