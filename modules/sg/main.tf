locals {
  region      = var.region
  environment = var.environment
  identifier  = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

# Data block to fetch security group by name for ingress
data "aws_security_group" "ingress_by_name" {
  for_each = var.ingress_sg
  name     = each.key
  vpc_id   = each.value.vpc_id != null ? each.value.vpc_id : var.vpc_id
}

# Data block to fetch security group by name for egress
data "aws_security_group" "egress_by_name" {
  for_each = var.egress_sg
  name     = each.key
}

resource "aws_security_group" "sg" {
  name        = local.identifier
  description = "Security group for ${local.identifier}"
  vpc_id      = var.vpc_id

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = concat(
      var.ingress_rules,
      var.ingress_sg_ids,
      [for sg_key, sg_value in data.aws_security_group.ingress_by_name : {
        security_groups = [sg_value.id]
        description     = var.ingress_sg[sg_key].description
        from_port       = var.ingress_sg[sg_key].from_port
        to_port         = var.ingress_sg[sg_key].to_port
        protocol        = var.ingress_sg[sg_key].protocol
      }]
    )
    content {
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = concat(
      var.egress_rules,
      [for sg_key, sg_value in data.aws_security_group.egress_by_name : {
        security_groups = [sg_value.id]
        description     = var.egress_sg[sg_key].description
        from_port       = var.egress_sg[sg_key].from_port
        to_port         = var.egress_sg[sg_key].to_port
        protocol        = var.egress_sg[sg_key].protocol
      }]
    )
    content {
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      security_groups = lookup(egress.value, "security_groups", null)
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
    }
  }

  tags = merge(var.tags, { Name = local.identifier })
}
