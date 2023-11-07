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
variable "aws_public_routetable_sufx" {
  type = string
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
variable "aws_customer_gateway_ip" {
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
variable "ansible_strongswan_vars_file" {
    type = string
}
variable "ovh_loopback_ip" {
  type = string
}
