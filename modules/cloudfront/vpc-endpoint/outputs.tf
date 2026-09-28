output "vpc_endpoint" {
  description = "VPC endpoint"
  value       = aws_cloudfront_vpc_origin.endpoint
}
