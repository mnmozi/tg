terraform {
  source = "${get_repo_root()}/modules//lt"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "sg" {
  config_path = "../00-sg"
}

dependency "cluster" {
  config_path = "${get_parent_terragrunt_dir()}/10-applications/00-common/ecs-clusters/yozo-applications"
}

inputs = {
  default_version = 1
  arch            = "x86_64"
  distro          = "amazon-linux-ecs"

  required_tags = {
    project   = "yozo"
    component = "ecs-m6i-large"
  }

  tags = {}

  instance_type = "m6i.large"
  key_name      = "dev-instance"

  spot_enabled = false
  cpu_credits  = "unlimited"

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

  user_data = base64encode(<<-EOT
    #!/bin/bash
    echo ECS_CLUSTER=${dependency.cluster.outputs.cluster_name} >> /etc/ecs/ecs.config
  EOT
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
