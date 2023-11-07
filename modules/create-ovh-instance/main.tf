# Create OVH instance

# Creating an SSH key pair resource
resource "openstack_compute_keypair_v2" "self_keypair" {
  provider   = openstack.ovh                # Provider name declared in provider.tf
  name       = "${var.pod}${var.ssh_ovh_key_name_sufx}"             # Name of the SSH key to use for creation
  
}

# Creating the instance
resource "openstack_compute_instance_v2" "sell_terraform_instance" {
  name        = "${var.pod}${var.ovh_instance_name_sufx}"     # Instance name
  provider    = openstack.ovh                       # Provider name
  image_name  = var.ovh_image_name        # Image name Ubuntu 22.04
  flavor_name = var.ovh_flavor_name       # Instance type name
  # Name of openstack_compute_keypair_v2 resource named keypair_test
  key_pair    = openstack_compute_keypair_v2.self_keypair.name
  network {
    name      = var.ovh_network_name      # Adds the network component to reach your instance
  }
}

# get the private key on local file
resource "local_file" "privatekey_filename" {
    content = "${openstack_compute_keypair_v2.self_keypair.private_key}"
    filename = var.ssh_ovh_privatekey_file_name
    file_permission = "0600"
}