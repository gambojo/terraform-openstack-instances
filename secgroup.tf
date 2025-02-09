# security group
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.network.net_name}_secgroup"
  description = "${var.network.net_name}_secgroup"
}

# security group rules
resource "openstack_networking_secgroup_rule_v2" "secgroup_rules" {
  count             = length(var.secgroup_rules)
  direction         = coalesce(var.secgroup_rules[count.index].direction, "ingress")
  ethertype         = var.secgroup_rules[count.index].ethertype
  protocol          = var.secgroup_rules[count.index].protocol
  port_range_min    = var.secgroup_rules[count.index].port_range.min
  port_range_max    = var.secgroup_rules[count.index].port_range.max
  remote_ip_prefix  = coalesce(
    var.secgroup_rules[count.index].prefix,
    var.secgroup_rules[count.index].ethertype == "IPv4" ? "0.0.0.0/0" : "::/0"
  )
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
