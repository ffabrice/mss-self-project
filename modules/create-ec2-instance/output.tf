output "aws_ec2_instance_public_ip" {
  value = resource.aws_instance.aws-ec2-instance-tf-sell.public_ip
}
output "aws_ec2_instance_private_ip" {
  value = resource.aws_instance.aws-ec2-instance-tf-sell.private_ip
}