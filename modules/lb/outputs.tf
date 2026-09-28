output "alb" {
  value = aws_lb.lb
}

output "dns_name" {
  value = aws_lb.lb.dns_name
}

output "zone_id" {
  value = aws_lb.lb.zone_id
}

output "listeners" {
  description = "Map of all listeners with the port as the key and their details as the value"
  value = {
    for listener in aws_lb_listener.listeners :
    listener.port => {
      protocol = listener.protocol,
      arn      = listener.arn
    }
  }
}

