terraform {
  source = "${path_relative_from_include()}/../../../modules/lt"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# dependency "vpc" {
#   config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
# }

dependency "sg" {
  config_path = "../00-sg"
}

inputs = {
  default_version = 1
  # lt_name = "prod-launch-template"
  # iam_policy_name = "prod-iam-policy"
  # iam_role_name   = "prod-iam-role"
  arch   = "x86_64"
  distro = "amazon-linux-ecs"

  required_tags = {
    project   = "malab"
    component = "cluster-m6i.large"
  }

  tags = {}

  instance_type = "m6i.large"
  key_name      = "dev-instance"

  spot_enabled = false
  # spot_instance_type = "one-time"


  cpu_credits = "unlimited"

  disable_api_stop        = false
  disable_api_termination = false
  ebs_optimized           = true

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  monitoring                  = true
  associate_public_ip_address = false
  sg_ids                      = [dependency.sg.outputs.id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=prod-malaeb-cluster >> /etc/ecs/ecs.config
  EOF
  )
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
