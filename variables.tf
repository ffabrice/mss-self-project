variable "pod" {
  type = string
}
variable "ssh_ovh_key_name_sufx" {
  type = string
}
variable "ssh_ovh_privatekey_file_name" {
  type = string
}
variable "ovh_instance_name_sufx" {
  type = string
}
variable "ovh_image_name" {
  type = string
}
variable "ovh_flavor_name" {
  type = string
}
variable "ovh_network_name" {
  type = string
}
variable "ovh_loopback_ip" {
  type = string
}
variable "ovh_instance_ip" {
  type = string
  default = ""
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
variable "aws_security_group_sufx_https" {
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
variable "aws_ec2_instance_public_ip" {
  type = string
  default = ""
}
variable "aws_ec2_instance_private_ip" {
  type = string
  default = ""
}
variable "aws_public_routetabletovgw_sufx" {
  type = string
}
variable "aws_vpngw_sufx" {
  type = string
}
variable "aws_customergw_sufx" {
  type = string
}
variable "aws_customer_gateway_asn" {
  type = string
}
variable "aws_customer_gateway_type" {
  type = string
}
variable "aws_vpn_connection_type" {
  type = string
}
variable "aws_vpn_connection_sufx" {
  type = string
}
variable "aws_vpn_connection_destination" {
  type = string
}
variable "aws_dns_zone" {
  type = string
}
variable "ansible_nginx_config_file" {
  type = string
}
variable "ansible_nginx_inventory_file" {
  type = string
}
variable "ansible_nginx_playbook" {
  type = string
}
variable "ansible_website_config_file" {
  type = string
}
variable "ansible_website_generic_file" {
  type = string
}
variable "ansible_website_inventory_file" {
  type = string
}
variable "ansible_website_playbook" {
  type = string
}
variable "ansible_vhost_playbook" {
  type = string
}
variable "ansible_certificate_playbook" {
  type = string
}
variable "ansible_strongswan_vars_file" {
  type = string
}
variable "ansible_strongswan_config_file" {
  type = string
}
variable "ansible_strongswan_inventory_file" {
  type = string
}
variable "ansible_strongswan_playbook" {
  type = string
}
variable "ansible_check_conf" {
  type = string
}
variable "ansible_check_inventory_file" {
  type = string
}
variable "ansible_check_vars_file" {
  type = string
}