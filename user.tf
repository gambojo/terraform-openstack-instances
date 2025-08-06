# Create key pair for user
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = coalesce(
    var.user.ssh_keybits,
    2048
  )
}

# Import users key pair to openstack
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.network.net_name}_keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save users key pair to file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/${coalesce(
    var.user.ssh_keyname,
    "ssh.key"
  )}"
  file_permission = "0600"
}

# Hashing plain password
data "external" "password_hasher" {
  program = ["bash", "${path.module}/pwhasher.sh"]
  query = {
    password = var.user.password
  }
}

# User settings configuration template
data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    user_name     = var.user.name
    user_password = data.external.password_hasher.result.hash
    public_key    = openstack_compute_keypair_v2.keypair.public_key
  }
}
