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

data "aws_launch_template" "default" {
  name = var.launch_template_name != null ? var.launch_template_name : local.asg_identifier
}

data "aws_lb_target_group" "tgs" {
  count = length(var.target_groups_names)

  name = var.target_groups_names[count.index]
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

  dynamic "launch_template" {
    for_each = (var.launch_template != null || var.launch_template_name != null) && var.mixed_instance_policy == null ? [1] : []
    content {
      id      = var.launch_template != null ? var.launch_template.id : data.aws_launch_template.default.id
      version = var.launch_template != null ? var.launch_template.version : data.aws_launch_template.default.latest_version
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.mixed_instance_policy != null ? [1] : []
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
          launch_template_id = var.launch_template.id != null ? var.launch_template.id : data.aws_launch_template.default.id
          version            = var.launch_template.version != null ? var.launch_template.version : data.aws_launch_template.default.latest_version
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
  target_group_arns = concat(var.target_groups_arns, data.aws_lb_target_group.tgs[*].arn)


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
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
