data "aws_route53_zone" "lookup" {
  count        = var.zone_id == null ? 1 : 0
  name         = var.zone_name
  private_zone = var.private_zone
}

locals {
  zone_id = var.zone_id != null ? var.zone_id : data.aws_route53_zone.lookup[0].zone_id
}

resource "aws_route53_record" "record" {
  zone_id = local.zone_id
  name    = var.record.name
  type    = var.record.type
  ttl     = lookup(var.record, "ttl", null)

  dynamic "weighted_routing_policy" {
    for_each = lookup(var.record, "weight", null) != null ? [var.record] : []
    content {
      weight = var.record.weight
    }
  }

  dynamic "alias" {
    for_each = can(var.record.alias.name) && can(var.record.alias.zone_id) ? [var.record.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }


  records        = lookup(var.record, "records", null)
  set_identifier = lookup(var.record, "set_identifier", null)
}
