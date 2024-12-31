terraform {
  source = "${path_relative_from_include()}/../../../modules/lt"
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

inputs = {
  default_version = 1
  # lt_name = "prod-launch-template"
  # iam_policy_name = "prod-iam-policy"
  # iam_role_name   = "prod-iam-role"
  arch   = "x86_64"
  distro = "ubuntu"

  required_tags = {
    project   = "yozo"
    component = "cluster-t3-small-cp"
  }

  tags = {}

  instance_type = "t3.small"
  key_name      = "proscripe-prod"

  spot_enabled = false
  # spot_instance_type = "one-time"


  cpu_credits = "unlimited"

  disable_api_stop        = false
  disable_api_termination = false
  ebs_optimized           = true

  metadata = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring                  = true
  associate_public_ip_address = true
  sg_ids                      = [dependency.sg.outputs.sg.id]

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        iops                  = 3000
        throughput            = 125
        volume_size           = 30
        volume_type           = "gp3"
      }
    },
  ]
}
