pod                                 = "selfmsss"  
ssh_ovh_key_name_sufx               = "_ovh_keypair"        
ssh_ovh_privatekey_file_name        = "./.ssh/self_ovh_keypair_rsa.pem"   
ovh_instance_name_sufx              = "_ovh_instance" 
ovh_image_name                      = "Ubuntu 22.04"
ovh_flavor_name                     = "d2-2"
ovh_network_name                    = "Ext-Net"
aws_region                          = "us-east-2"
aws_vpc_sufx                        = "vpc"
aws_cidr_vpc                        = "10.1.0.0/16"
aws_subnet_public_sufx              = "public-subnet"
aws_cidr_public                     = "10.1.1.0/24"
aws_subnet_private_sufx             = "private-subnet"
aws_cidr_private                    = "10.1.2.0/24"
aws_public_routetable_sufx          = "public-route-table"
aws_public_routetable_cidr_block    = "0.0.0.0/0"
aws_internet_gateway_sufx           = "igw"
aws_security_group_sufx_ssh         = "ssh-security-group"
aws_security_group_sufx_rdp         = "rdp-security-group"
aws_security_group_sufx_icmp        = "icmp-security-group"
aws_security_group_sufx_http        = "http-security-group"
aws_security_group_sufx_https       = "https-security-group"
ssh_aws_key_name_sufx               = "_aws_keypair" 
aws_algorithm_name                  = "RSA"
aws_rsa_bits                        = 4096
ssh_aws_private_key_filename        = "./.ssh/self_aws_keypair_rsa.pem" 
aws_ami_filter_name_name            = "name"
aws_ami_filter_name_value           = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
aws_ami_filter_architecture_name    = "architecture"
aws_ami_filter_architecture_value   = "x86_64"
aws_ami_owner                       = "099720109477"
aws_ec2_instance_type               = "t2.nano"
aws_ec2_instance_sufx               = "ec2-instance"
aws_public_routetabletovgw_sufx     = "public-route-to-vgw-table"
aws_vpngw_sufx                      = "vpngw"
aws_customergw_sufx                 = "customergw"
aws_customer_gateway_asn            = "65000"
aws_customer_gateway_type           = "ipsec.1"
aws_vpn_connection_type             = "ipsec.1"
aws_vpn_connection_sufx             = "vpn"
aws_vpn_connection_destination      = "10.10.1.0/24"
ovh_loopback_ip                     = "10.10.1.252"
aws_dns_zone                        = "devops.intuitivesoft.cloud."
ansible_nginx_config_file           = "./modules/install-nginx-on-ec2/ansible.cfg"
ansible_nginx_inventory_file        = "./modules/install-nginx-on-ec2/inventory.ini"
ansible_nginx_playbook              = "./modules/install-nginx-on-ec2/nginx-install.yml"
ansible_website_config_file         = "./modules/deploy-website/ansible.cfg"
ansible_website_generic_file        = "./modules/deploy-website/vars/generic.yml"
ansible_website_inventory_file      = "./modules/deploy-website/inventory.ini"
ansible_website_playbook            = "./modules/deploy-website/deploy-website.yml"
ansible_vhost_playbook              = "./modules/deploy-website/create-vhost.yml"
ansible_certificate_playbook        = "./modules/deploy-website/deploy-certificate.yml"
ansible_strongswan_vars_file        = "./modules/install-strongswan-on-ovh/vars/variables.yml"
ansible_strongswan_config_file      = "./modules/install-strongswan-on-ovh/ansible.cfg"
ansible_strongswan_inventory_file   = "./modules/install-strongswan-on-ovh/inventory.ini"
ansible_strongswan_playbook         = "./modules/install-strongswan-on-ovh/strongswan-install.yml"
ansible_check_conf                  = "./modules/check-conf/check-conf.yml"
ansible_check_inventory_file        = "./modules/check-conf/inventory.ini"
ansible_check_vars_file             = "./modules/check-conf/vars/variables.yml"
