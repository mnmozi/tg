
output "id" {
  description = "The ami id"
  value       = aws_ami_from_instance.ami.id
}

output "ami" {
  description = "The ami id"
  value       = aws_ami_from_instance.ami
}
output "name" {
  description = "The ami id"
  value       = aws_ami_from_instance.ami.name
}

output "ebs_block_device" {
  value = aws_ami_from_instance.ami.ebs_block_device
}
