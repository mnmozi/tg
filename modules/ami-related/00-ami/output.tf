
output "id" {
  description = "The ami id"
  value       = aws_ami_from_instance.solr-ami.id
}

output "ami" {
  description = "The ami id"
  value       = aws_ami_from_instance.solr-ami
}
output "name" {
  description = "The ami id"
  value       = aws_ami_from_instance.solr-ami.name
}

output "sdf_ebs_block_device" {
  value = tomap({
    for ebs in aws_ami_from_instance.solr-ami.ebs_block_device :
    ebs.device_name => ebs
    if ebs.device_name == "/dev/sdf"
  })["/dev/sdf"]
}

output "sdg_ebs_block_device" {
  value = tomap({
    for ebs in aws_ami_from_instance.solr-ami.ebs_block_device :
    ebs.device_name => ebs
    if ebs.device_name == "/dev/sdg"
  })["/dev/sdg"]
}
