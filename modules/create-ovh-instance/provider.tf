# providers

# openstack
terraform {                  
    required_providers {
        openstack = {
            source  = "terraform-provider-openstack/openstack"
            version = "~> 1.42.0"                   # Specify provider minimal version
        }
    }
}

# Configure the OpenStack provider hosted by OVHcloud
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/"    # Authentication URL
  domain_name = "default"                           # Domain name - Always at 'default' for OVHcloud
  alias       = "ovh"                               # An alias
}
