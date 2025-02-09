# Get image id
data "openstack_images_image_v2" "image" {
  count       = length(var.instances)
  name        = coalesce(var.instances[count.index].image, "ubuntu-22.04.4")
  most_recent = true

  properties = {
    key = "value"
  }
}

# Create key pair
resource "openstack_compute_keypair_v2" "keypair" {
  name = "${var.network.net_name}_keypair"
}

# Create instances
resource "openstack_compute_instance_v2" "instance" {
  count       = length(var.instances)
  name        = var.instances[count.index].name
  image_id    = data.openstack_images_image_v2.image[count.index].id
  flavor_name = coalesce(var.instances[count.index].flavor, "2-4-0")
  key_pair    = "${var.network.net_name}_keypair"
  user_data   = base64encode(data.template_file.user_data.rendered)

  block_device {
    uuid                  = data.openstack_images_image_v2.image[count.index].id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = coalesce(var.instances[count.index].volume_size, 10)
  }

  network {
    name = "${var.network.net_name}_network"
    port = openstack_networking_port_v2.port[count.index].id
  }

  depends_on = [
    openstack_networking_network_v2.network,
    openstack_networking_subnet_v2.subnet,
    openstack_networking_port_v2.port
  ]
}
