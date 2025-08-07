# Get image id
data "openstack_images_image_v2" "image" {
  count       = length(var.instances)
  name        = coalesce(
    var.instances[count.index].image,
    var.instance_defaults.image
  )
  most_recent = true

  properties = {
    key = "value"
  }
}

# Create instances
resource "openstack_compute_instance_v2" "instance" {
  count       = length(var.instances)
  name        = var.instances[count.index].name
  image_id    = data.openstack_images_image_v2.image[count.index].id
  flavor_name = coalesce(
    var.instances[count.index].flavor,
    var.instance_defaults.flavor
  )
  key_pair    = "${var.network.net_name}_keypair"
  user_data   = base64encode(data.template_file.user_data.rendered)

  block_device {
    uuid                  = data.openstack_images_image_v2.image[count.index].id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = coalesce(
      var.instances[count.index].volume_size,
      var.instance_defaults.volume_size
    )
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

# Get information of instances
locals {
  instances_info = {
    for idx, instance in openstack_compute_instance_v2.instance :
    instance.name => {
      external_ip = openstack_networking_floatingip_v2.fip[idx].address
      internal_ip = instance.network[0].fixed_ip_v4
    }
  }

  depends_on = [
    openstack_compute_instance_v2.instance,
    openstack_networking_floatingip_associate_v2.fip_associate
  ]
}

# Import instances info to invertory file for ansible in ./outputs/
resource "local_file" "invertory" {
  filename = "${path.module}/outputs/invertory.yml"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    timestamp = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
    username  = var.user.name
    ssh_key   = abspath("${path.module}/outputs/ssh.key")
    instances = local.instances_info
  })
}

# Output info
output "info" {
  value = "ssh private key and ansible inventory with info about connection saved in  ./outputs/ directory!"
}
