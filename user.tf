# Create key pair for user
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "${var.user.ssh_keybits}"
}

# Import users key pair to openstack
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.network.net_name}_keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save users key pair to file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/${var.user.ssh_keyname}"
  file_permission = "0600"
}

# User settings configuration template
data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    user_name     = var.user.name
    user_password = var.user.hashed_password
    public_key    = openstack_compute_keypair_v2.keypair.public_key
  }
}

output "username" {
  value = "${var.user.name}"
}
