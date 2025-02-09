# Instance parameters
variable "instances" {
  type = list(object({
    name        = string,
    image       = optional(string),
    flavor      = optional(string),
    volume_size = optional(number)
  }))

  default = [
    {
      name        = "terraform-instance",
      image       = "ubuntu-22.04.4",
      flavor      = "2-4-0",
      volume_size = 10
    }
  ]
}

# Security group rules
variable "secgroup_rules" {
  type = list(object({
    port_range = object({
      min = number,
      max = number
    }),
    protocol  = string,
    ethertype = string,
    direction = optional(string),
    prefix    = optional(string)
  }))

  default = [
    {
      port_range = {
        min = 22,
        max = 22
      },
      protocol  = "tcp",
      ethertype = "IPv4",
      direction = "ingress",
      prefix    = "0.0.0.0/0"
    }
  ]
}

# Network parameters
variable "network" {
  type = object({
    net_name        = string,
    extnet_name     = string,
    cidr_block      = optional(string),
    dns_nameservers = optional(list(string))
  })

  default = {
    net_name        = "terraform",
    extnet_name     = "external",
    cidr_block      = "192.168.0.0/24",
    dns_nameservers = ["8.8.8.8"]
  }
}

# User parameters
variable "user" {
  type = object({
    name            = string,
    hashed_password = string
  })

  default = {
    name            = "terraform",
    hashed_password = "$6$any_salt$hwzTmqWFVZOgxgMB5LeaFoA2hkb.xujnbNiMQ/50shLK25XrnvdzXtKeh1yn/7Ve9OZ2k1g2fJQ3CJYiYCrf8."
  }
}
