output "nat_gateway_id" {
  description = "NAT gateway ID."
  value       = aws_nat_gateway.nat-gateway.id
}

output "nat_gateway_ip" {
  description = "Elastic IP attached to the NAT gateway."
  value       = aws_eip.nat-gateway-eip.public_ip
}
