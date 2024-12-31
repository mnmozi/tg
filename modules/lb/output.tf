output "alb" {
  value = aws_lb.lb
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
