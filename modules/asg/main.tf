locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  asg_identifier = (var.asg_name == null || var.asg_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.asg_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.asg_identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

resource "aws_autoscaling_group" "asg" {
  name                      = local.asg_identifier
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  min_elb_capacity          = var.desired_capacity
  force_delete              = var.force_delete

  vpc_zone_identifier = var.vpc_zone_identifier


  desired_capacity_type = var.desired_capacity_type
  capacity_rebalance    = var.capacity_rebalance
  dynamic "mixed_instances_policy" {
    for_each = var.instance_type == "" ? [1] : []
    content {
      instances_distribution {
        on_demand_allocation_strategy            = "prioritized"
        on_demand_base_capacity                  = lookup(var.mixed_instance_policy, "on_demand_base_capacity", 0)
        on_demand_percentage_above_base_capacity = lookup(var.mixed_instance_policy, "on_demand_percentage_above_base_capacity", 0)
        spot_allocation_strategy                 = lookup(var.mixed_instance_policy, "spot_allocation_strategy", "price-capacity-optimized")
        spot_instance_pools                      = lookup(var.mixed_instance_policy, "spot_instance_pools", 0)
      }
      launch_template {
        launch_template_specification {
          launch_template_id = var.mixed_instance_policy.launch_template_id
          version            = var.mixed_instance_policy.launch_template_version
        }
        dynamic "override" {
          for_each = var.mixed_instance_policy.override
          content {
            instance_type     = override.value.instance_type
            weighted_capacity = override.value.weighted_capacity
          }
        }
      }
    }
  }
  target_group_arns = var.target_group_arns

  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}
