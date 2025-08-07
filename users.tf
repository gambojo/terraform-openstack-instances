# Create key pair for user
resource "tls_private_key" "ssh_keypair" {
  algorithm = "RSA"
  rsa_bits = coalesce(
    var.user.ssh_keybits,
    2048
  )
}

# Export users public key to openstack
resource "openstack_compute_keypair_v2" "public_key" {
  name       = "${var.network.net_name}_keypair"
  public_key = tls_private_key.ssh_keypair.public_key_openssh
}

# Import users private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_keypair.private_key_pem
  filename = "${path.module}/outputs/${coalesce(
    var.user.ssh_keyname,
    "ssh.key"
  )}"
  file_permission = "0600"
}

# Hashing users password
data "external" "password_hasher" {
  program = ["bash", "${path.module}/templates/pwhasher.sh"]
  query = {
    password = var.user.password
  }
}

# Create user via cloud-config
data "template_file" "user_data" {
  template = file("${path.module}/templates/users.tpl")

  vars = {
    user_name     = var.user.name
    user_password = data.external.password_hasher.result.hash
    public_key    = openstack_compute_keypair_v2.public_key.public_key
  }
}
