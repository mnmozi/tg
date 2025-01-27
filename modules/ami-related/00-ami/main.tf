locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = (var.ami_name == null || var.ami_name == "") ? "latest-${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.ami_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

resource "aws_ami_from_instance" "ami" {
  name                    = local.identifier
  source_instance_id      = var.instance_id
  snapshot_without_reboot = var.snapshot_without_reboot
  tags                    = local.tags
}

resource "aws_ec2_tag" "snapshot_tags" {
  for_each    = local.tags
  resource_id = aws_ami_from_instance.ami.root_snapshot_id
  key         = each.key
  value       = each.value
}
