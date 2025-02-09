# Output floating ip addresses
output "floating_ip" {
  value = [for fip in openstack_networking_floatingip_v2.fip : fip.address]
}

# Output private key
output "private_key" {
  value     = openstack_compute_keypair_v2.keypair.private_key
  sensitive = true
}
