# Root terraform orchestrator


###############################################################################
# Create an OVH instance 
###############################################################################
module "create-ovh-instance" {
    source = "./modules/create-ovh-instance"
    pod                           = var.pod
    ssh_ovh_key_name_sufx         = var.ssh_ovh_key_name_sufx
    ssh_ovh_privatekey_file_name  = var.ssh_ovh_privatekey_file_name
    ovh_instance_name_sufx        = var.ovh_instance_name_sufx
    ovh_image_name                = var.ovh_image_name
    ovh_flavor_name               = var.ovh_flavor_name
    ovh_network_name              = var.ovh_network_name
}


###############################################################################
# Create an AWS EC2 instance
###############################################################################
module "create-ec2-instance" {
    source = "./modules/create-ec2-instance"
    aws_pod                           = var.pod
    aws_region                        = var.aws_region
    aws_vpc_sufx                      = var.aws_vpc_sufx
    aws_cidr_vpc                      = var.aws_cidr_vpc
    aws_subnet_public_sufx            = var.aws_subnet_public_sufx
    aws_cidr_public                   = var.aws_cidr_public
    aws_subnet_private_sufx           = var.aws_subnet_private_sufx
    aws_cidr_private                  = var.aws_cidr_private
    aws_public_routetable_sufx        = var.aws_public_routetable_sufx
    aws_public_routetable_cidr_block  = var.aws_public_routetable_cidr_block
    aws_internet_gateway_sufx         = var.aws_internet_gateway_sufx
    aws_security_group_sufx_ssh       = var.aws_security_group_sufx_ssh
    aws_security_group_sufx_rdp       = var.aws_security_group_sufx_rdp
    aws_security_group_sufx_icmp      = var.aws_security_group_sufx_icmp
    aws_security_group_sufx_http      = var.aws_security_group_sufx_http
    ssh_aws_key_name_sufx             = var.ssh_aws_key_name_sufx
    aws_algorithm_name                = var.aws_algorithm_name
    aws_rsa_bits                      = var.aws_rsa_bits
    ssh_aws_private_key_filename      = var.ssh_aws_private_key_filename
    aws_ami_filter_name_name          = var.aws_ami_filter_name_name
    aws_ami_filter_name_value         = var.aws_ami_filter_name_value
    aws_ami_filter_architecture_name  = var.aws_ami_filter_architecture_name
    aws_ami_filter_architecture_value = var.aws_ami_filter_architecture_value
    aws_ami_owner                     = var.aws_ami_owner
    aws_ec2_instance_type             = var.aws_ec2_instance_type
    aws_ec2_instance_sufx             = var.aws_ec2_instance_sufx
    aws_dns_zone                      = var.aws_dns_zone
    aws_dns_record                    = var.pod
}


###############################################################################
# Install nginx on EC2 instance
###############################################################################
# Generate config file
resource "local_file" "aws_ansible_nginx_config_file" {
  filename = "${var.ansible_nginx_config_file}"
  content = <<-EOT
   [defaults]
   host_key_checking = False
  EOT
}

# Generate inventory file
resource "local_file" "aws_ansible_nginx_inventory_file" {
  filename = "${var.ansible_nginx_inventory_file}"
  content = <<-EOT
   [webservers]
   nginx ansible_host=${module.create-ec2-instance.aws_ec2_instance_public_ip}

   [webservers:vars]
   ansible_ssh_private_key_file="${var.ssh_aws_private_key_filename}"
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
   ansible_user=ubuntu
  EOT
}

# Check EC2 instance is up and install nginx if it is
resource "null_resource" "aws_ansible_nginx_playbook" {
  #wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.aws_ansible_nginx_inventory_file.content)
  }
  depends_on = [
    module.create-ec2-instance,
    local_file.aws_ansible_nginx_config_file,
    local_file.aws_ansible_nginx_inventory_file
    ]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ec2-instance.aws_ec2_instance_public_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_aws_private_key_filename}")
    }

    inline = ["echo 'connected!'"]
  }

  # Install nginx on AWS EC2 instance
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_nginx_inventory_file} ${var.ansible_nginx_playbook}"
  }
}


###############################################################################
# Deploy VPN connection on AWS side
###############################################################################
# Deploy a VPN connection
module "deploy-vpn-connection" {
    source = "./modules/deploy-vpn-connection"
    aws_customer_gateway_ip           = module.create-ovh-instance.ovh_instance_ip
    aws_pod                           = var.pod
    aws_region                        = var.aws_region
    aws_vpc_sufx                      = var.aws_vpc_sufx
    aws_cidr_vpc                      = var.aws_cidr_vpc
    aws_public_routetable_sufx        = var.aws_public_routetable_sufx
    aws_public_routetabletovgw_sufx   = var.aws_public_routetabletovgw_sufx
    aws_vpngw_sufx                    = var.aws_vpngw_sufx
    aws_customergw_sufx               = var.aws_customergw_sufx
    aws_customer_gateway_asn          = var.aws_customer_gateway_asn
    aws_customer_gateway_type         = var.aws_customer_gateway_type
    aws_vpn_connection_type           = var.aws_vpn_connection_type
    aws_vpn_connection_sufx           = var.aws_vpn_connection_sufx
    aws_vpn_connection_destination    = var.aws_vpn_connection_destination
    ansible_strongswan_vars_file      = var.ansible_strongswan_vars_file
    ovh_loopback_ip                   = var.ovh_loopback_ip

    depends_on = [module.create-ec2-instance]
}


###############################################################################
# Install strongswan on ovh instance
###############################################################################
# Generate config file
resource "local_file" "ovh_ansible_config_file" {
  filename = "${var.ansible_strongswan_config_file}"
  content = <<-EOT
   [defaults]
   host_key_checking = False
  EOT
}

# Generate inventory file
resource "local_file" "ovh_ansible_inventory_file" {
  filename = "${var.ansible_strongswan_inventory_file}"
  content = <<-EOT
   [webservers]
   strongswan ansible_host=${module.create-ovh-instance.ovh_instance_ip}

   [webservers:vars]
   ansible_ssh_private_key_file="${var.ssh_ovh_privatekey_file_name}"
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
   ansible_user=ubuntu
  EOT
}

# Check OVH instance is up and install strongswan if it is
resource "null_resource" "ovh_strongswan_playbook" {
  # Wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.ovh_ansible_inventory_file.content)
  }
  depends_on = [module.create-ovh-instance,
    module.deploy-vpn-connection,
    local_file.ovh_ansible_config_file,
    local_file.ovh_ansible_inventory_file
    ]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ovh-instance.ovh_instance_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_ovh_privatekey_file_name}")
    }

    inline = ["echo 'connected!'"]
  }

  # Install strongswan on OVH instance
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_strongswan_inventory_file} ${var.ansible_strongswan_playbook}"
  }
}


###############################################################################
# Create vhost on nginx
###############################################################################
# Generate config file
resource "local_file" "aws_ansible_website_config_file" {
  filename = "${var.ansible_website_config_file}"
  content = <<-EOT
   [defaults]
   host_key_checking = False
  EOT
}

# Generate inventory file
resource "local_file" "aws_ansible_website_inventory_file" {
  filename = "${var.ansible_website_inventory_file}"
  content = <<-EOT
   [webservers]
   nginx ansible_host=${module.create-ec2-instance.aws_ec2_instance_public_ip}

   [webservers:vars]
   ansible_ssh_private_key_file="${var.ssh_aws_private_key_filename}"
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
   ansible_user=ubuntu
  EOT
}

# Generate generic file
resource "local_file" "aws_ansible_website_generic_file" {
  filename = "${var.ansible_website_generic_file}"
  content = <<-EOT
   domain: ${var.pod}.${var.aws_dns_zone}
  EOT
}

# Create vhost 
resource "null_resource" "aws_ansible_vhost_playbook" {
  #wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.aws_ansible_website_inventory_file.content)
  }
  depends_on = [
    module.create-ec2-instance,
    local_file.aws_ansible_website_config_file,
    local_file.aws_ansible_website_inventory_file,
    local_file.aws_ansible_website_generic_file,
    null_resource.aws_ansible_nginx_playbook
    ]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ec2-instance.aws_ec2_instance_public_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_aws_private_key_filename}")
    }

    inline = ["echo 'connected!'"]
  }

  # Create vhost
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_website_inventory_file} ${var.ansible_vhost_playbook}"
  }
}


###############################################################################
# Deploy website on nginx
###############################################################################
resource "null_resource" "aws_ansible_website_playbook" {
  # Wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.aws_ansible_website_inventory_file.content)
  }
  depends_on = [
    module.create-ec2-instance,
    local_file.aws_ansible_website_config_file,
    local_file.aws_ansible_website_inventory_file,
    null_resource.aws_ansible_nginx_playbook,
    null_resource.aws_ansible_vhost_playbook
    ]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ec2-instance.aws_ec2_instance_public_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_aws_private_key_filename}")
    }

    inline = ["echo 'connected!'"]
  }

  # Deploy website
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_website_inventory_file} ${var.ansible_vhost_playbook};ansible-playbook -i ${var.ansible_website_inventory_file} ${var.ansible_website_playbook}"
  }
}


###############################################################################
# Deploy certificate on website
###############################################################################
resource "null_resource" "aws_ansible_certificate_playbook" {
  # Wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.aws_ansible_website_inventory_file.content)
  }
  depends_on = [
    module.create-ec2-instance,
    local_file.aws_ansible_website_config_file,
    local_file.aws_ansible_website_inventory_file,
    null_resource.aws_ansible_nginx_playbook,
    null_resource.aws_ansible_vhost_playbook,
    null_resource.aws_ansible_website_playbook
    ]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ec2-instance.aws_ec2_instance_public_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_aws_private_key_filename}")
    }

    inline = ["echo 'connected!'"]
  }

  # Deploy certificate
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_website_inventory_file} ${var.ansible_certificate_playbook}"
  }
}


###############################################################################
# Check conf
###############################################################################
# Generate inventory file for check conf
resource "local_file" "ansible_check_inventory_file" {
  filename = "${var.ansible_check_inventory_file}"
  content = <<-EOT
    [ovhservers]
    strongswan ansible_host=${module.create-ovh-instance.ovh_instance_ip}

    [ovhservers:vars]
    ansible_ssh_private_key_file="${var.ssh_ovh_privatekey_file_name}"

    [awsservers]
    nginx ansible_host=${module.create-ec2-instance.aws_ec2_instance_public_ip}

    [awsservers:vars]
    ansible_ssh_private_key_file="${var.ssh_aws_private_key_filename}"

    [all:vars]
    ssh_common_args='-o StrictHostKeyChecking=no'
    ansible_user=ubuntu
  EOT
}

# Generate a vars file for check
resource "local_file" "ansible_check_vars_file" {
  filename = "${var.ansible_check_vars_file}"
  content = <<-EOT
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform mgmt configuration.
    ovh_loopback_ip: ${var.ovh_loopback_ip}
    aws_private_ip: ${module.create-ec2-instance.aws_ec2_instance_private_ip}
  EOT
}

# Check tunnels are up
resource "null_resource" "check_tunnels_up" {
  
  depends_on = [module.create-ovh-instance,
    module.deploy-vpn-connection,
    null_resource.ovh_strongswan_playbook,
    local_file.ansible_check_inventory_file,
    local_file.ansible_check_vars_file]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ovh-instance.ovh_instance_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_ovh_privatekey_file_name}")
    }

    inline = ["echo 'connected!'"]
  }

  # Ping ec2 from ovh the tunnel
  provisioner "local-exec" {
  command = "./checktunnelsup.sh ${module.deploy-vpn-connection.aws_vpn_connection_id} ${var.aws_region}"
  }
}


# Check : cross ping throw the tunnel
resource "null_resource" "check_conf" {
  # Wait for the vm instance to be created
  triggers = {
   file_changed = md5(local_file.ansible_check_vars_file.content)
  }
  depends_on = [module.create-ovh-instance,
    module.deploy-vpn-connection,
    null_resource.check_tunnels_up,
    local_file.ansible_check_inventory_file,
    local_file.ansible_check_vars_file,
    null_resource.check_tunnels_up]

  # Wait for the vm instance to be up
  provisioner "remote-exec" {
    connection {
      host = "${module.create-ovh-instance.ovh_instance_ip}"
      user = "ubuntu"
      private_key = file("${var.ssh_ovh_privatekey_file_name}")
    }

    inline = ["echo 'connected!'"]
  }

  # Ping ec2 from ovh the tunnel
  provisioner "local-exec" {
  command = "ansible-playbook -i ${var.ansible_check_inventory_file} ${var.ansible_check_conf}"
  }
}

###############################################################################
# Outputs
###############################################################################
# Display OVH Public IP Address allocated to instance
output "ovh_public_ip" {
  value = module.create-ovh-instance.ovh_instance_ip
}

# Display AWS Public IP Address allocated to instance
output "aws_public_ip" {
  value = module.create-ec2-instance.aws_ec2_instance_public_ip
}

# Display link to website
output "aws_link" {
  value = "https://${var.pod}.${var.aws_dns_zone}"
}
