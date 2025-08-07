# Get external network id
data "openstack_networking_network_v2" "external_network" {
  name = var.network.extnet_name
}

# Create internal network
resource "openstack_networking_network_v2" "network" {
  name           = "${var.network.net_name}_network"
  admin_state_up = "true"
  external       = "false"
  shared         = "false"
}

# Create subnet in internal network
resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.network.net_name}_subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = coalesce(var.network.cidr_block, "192.168.0.0/24")
  gateway_ip      = cidrhost(coalesce(var.network.cidr_block, "192.168.0.0/24"), 1)
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = coalesce(var.network.dns_nameservers, ["8.8.8.8"])
  depends_on      = [openstack_networking_network_v2.network]
}

# Create router for internal network
resource "openstack_networking_router_v2" "router" {
  name                = "${var.network.net_name}_router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
  depends_on          = [openstack_networking_subnet_v2.subnet]
}

# Create router interface
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id  = openstack_networking_router_v2.router.id
  subnet_id  = openstack_networking_subnet_v2.subnet.id
  depends_on = [openstack_networking_router_v2.router]
}

# Create network ports
resource "openstack_networking_port_v2" "port" {
  count          = length(var.instances)
  name           = var.instances[count.index].name
  network_id     = openstack_networking_network_v2.network.id
  admin_state_up = "true"
  depends_on     = [openstack_networking_subnet_v2.subnet]
}

# Create floating ip addresses from external network
resource "openstack_networking_floatingip_v2" "fip" {
  count      = length(var.instances)
  pool       = var.network.extnet_name
  depends_on = [openstack_networking_router_interface_v2.router_interface]
}

# Associate floating ip addresses with network ports
resource "openstack_networking_floatingip_associate_v2" "fip_associate" {
  count       = length(var.instances)
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
  port_id     = openstack_networking_port_v2.port[count.index].id
  depends_on  = [openstack_networking_floatingip_v2.fip]
}

# Associate network ports with security group
resource "openstack_networking_port_secgroup_associate_v2" "port_secgroup_associate" {
  count   = length(var.instances)
  port_id = openstack_networking_port_v2.port[count.index].id
  enforce = "true"
  security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
  depends_on = [openstack_networking_secgroup_rule_v2.secgroup_rules]
}
