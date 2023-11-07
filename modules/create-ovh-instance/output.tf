output "ovh_instance_ip" {
  value = openstack_compute_instance_v2.sell_terraform_instance.network[0].fixed_ip_v4
}