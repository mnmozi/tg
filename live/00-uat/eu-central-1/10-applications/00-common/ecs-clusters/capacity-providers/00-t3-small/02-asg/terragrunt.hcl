terraform {
  source = "${path_relative_from_include()}/../../../modules/asg"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}


dependency "lt" {
  config_path = "../01-lt"
}

inputs = {

  required_tags = {
    project   = "yozo"
    component = "applications-cp"
  }

  # Additional tags for resources
  tags = {}



  # Auto Scaling Group Configuration
  max_size                  = 5
  min_size                  = 0
  desired_capacity          = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = false
  desired_capacity_type     = "units"
  capacity_rebalance        = true
  vpc_zone_identifier       = [dependency.vpc.outputs.private_subnets[0], dependency.vpc.outputs.private_subnets[0]]

  # Mixed Instance Policy Configuration
  mixed_instance_policy = {
    on_demand_base_capacity                  = 1
    on_demand_percentage_above_base_capacity = 50
    spot_allocation_strategy                 = "capacity-optimized"
    spot_instance_pools                      = 0
    launch_template_id                       = dependency.lt.outputs.id
    launch_template_version                  = dependency.lt.outputs.default_version
    override                                 = []
    # override = [
    #   { instance_type = "t3.small", weighted_capacity = 1 },
    #   { instance_type = "t3.medium", weighted_capacity = 2 }
    # ]
  }

  # Target group ARNs for ASG
  # target_group_arns = [
  #   "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-target-group/abcd1234"
  # ]
}