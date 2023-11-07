variable "aws_pod" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "aws_vpc_sufx" {
  type = string
}
variable "aws_cidr_vpc" {
  type = string
}
variable "aws_cidr_public" {
  type = string
}
variable "aws_subnet_public_sufx" {
  type = string
}
variable "aws_cidr_private" {
  type = string
}
variable "aws_subnet_private_sufx" {
  type = string
}
variable "aws_internet_gateway_sufx" {
  type = string
}
variable "aws_public_routetable_cidr_block" {
  type = string
}
variable "aws_public_routetable_sufx" {
  type = string
}
variable "aws_security_group_sufx_ssh" {
  type = string
}
variable "aws_security_group_sufx_rdp" {
  type = string
}
variable "aws_security_group_sufx_icmp" {
  type = string
}
variable "aws_security_group_sufx_http" {
  type = string
}
variable "ssh_aws_key_name_sufx" {
  type = string
}
variable "aws_algorithm_name" {
  type = string
}
variable "aws_rsa_bits" {
  type = number
}
variable "ssh_aws_private_key_filename" {
  type = string
}
variable "aws_ami_filter_name_name" {
  type = string
}
variable "aws_ami_filter_name_value" {
  type = string
}
variable "aws_ami_filter_architecture_name" {
  type = string
}
variable "aws_ami_filter_architecture_value" {
  type = string
}
variable "aws_ami_owner" {
  type = string
}
variable "aws_ec2_instance_type" {
  type = string
}
variable "aws_ec2_instance_sufx" {
  type = string
}
variable "aws_dns_zone" {
  type = string
}
variable "aws_dns_record" {
  type = string
}