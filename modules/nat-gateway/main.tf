locals {
  region      = var.region
  environment = var.environment
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}


resource "aws_eip" "nat-gateway-eip" {
  public_ipv4_pool     = "amazon"
  network_border_group = local.region
  tags                 = merge(local.tags, { Name = "${local.environment}-nat" })
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id     = aws_eip.nat-gateway-eip.allocation_id
  connectivity_type = "public"
  subnet_id         = var.subnet_id

  tags       = merge(local.tags, { Name = "${local.environment}-nat" })
  depends_on = [aws_eip.nat-gateway-eip]
}

resource "aws_route" "route_rule" {
  for_each               = toset(var.route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
  depends_on             = [aws_nat_gateway.nat-gateway]
}
