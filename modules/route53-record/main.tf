data "aws_route53_zone" "selected" {
  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "records" {
  for_each = { for idx, record in var.records : idx => record }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)

  dynamic "weighted_routing_policy" {
    for_each = lookup(each.value, "weight", null) != null ? [each.value] : []
    content {
      weight = each.value.weight
    }
  }

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }

  records        = lookup(each.value, "records", null)
  set_identifier = lookup(each.value, "set_identifier", null)
}
