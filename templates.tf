# User settings configuration template
data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    user_name     = var.user.name
    user_password = var.user.hashed_password
    public_key    = openstack_compute_keypair_v2.keypair.public_key
  }
}
