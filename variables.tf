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

variable "instance_defaults" {
  type = object({
    image       = string,
    flavor      = string,
    volume_size = number
  })

  default = {
    image       = "debian-12.5.0"
    flavor      = "2-4-0"
    volume_size = 10
  }
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
    password        = string,
    ssh_keyname     = optional(string),
    ssh_keybits     = optional(number)
  })

  default = {
    name            = "terraform",
    password        = "terraform",
    ssh_keyname     = "ssh.key",
    ssh_keybits     = 2048
  }
}
