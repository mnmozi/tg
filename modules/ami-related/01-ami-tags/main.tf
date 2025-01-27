locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = var.ami_name
  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

# Set count based on the condition
resource "aws_ec2_tag" "snapshot_tags" {
  for_each = { for entry in distinct(flatten([
    for volume in var.ebs_block_device : [
      for tag, tag_value in local.tags : {
        snapshot_id = volume.snapshot_id
        tag         = tag
        tag_value   = tag_value
      }
    ]
    ])) : "${entry.snapshot_id}.${entry.tag}.${entry.tag_value}" => entry
  }

  resource_id = each.value.snapshot_id
  key         = each.value.tag
  value       = each.value.tag_value
}
