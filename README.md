# terraform-vps

## Title
- [Info](#info)
  - [Description](#description)
  - [More](#more)
- [Variables](#variables)
  - [General description of variables](#general-description-of-variables)
  - [Description of each variable](#description-of-each-variable)
- [Usage](#usage)
- [Requirements](#requirements)
---
<br />

## Info
#### Description
This simple terraform configuration will help you quickly deploy any number of different or identical instances by specifying a minimum amount of input data.<br />
Use TF_CLI_CONFIG_FILE=.terraformrc-yandex for define custom config
#### More
Default username/password `"terraform/terraform123"`<br />
We strongly recommend that you use your own password, for example for fast hashing you can use this command:
```sh
echo 'your_password' | openssl passwd -6 -salt 'your_salt' -stdin
```
To display the created private key, use the command:
```sh
terraform output --raw private_key
```
To display the created floating ip-addresses, use the command:
```sh
terraform output floating_ip
```
---
<br />

## Variables
### General description of variables
| Name | Description | Type |
|---|---|---|
| instances | Instance parameters | list(object) |
| secgroup_rules | Security group rules | list(object) |
| network | Network parameters | object |
| user | User parameters | object |

### Description of each variable
- instances
```hcl
instances = [
    {
        name        = string    # required  <any>            Default( terraform-instance )
        image       = string    # optional  <any>            Default( ubuntu-22.04.4 )
        flavor      = string    # optional  <any>            Default( 2-4-0 )
        volume_size = number    # optional  <any>            Default( 10 )
    }
]
```

- secgroup_rules
```hcl
secgroup_rules = [
    {
        port_range = {
            min     = number,   # required  <1-65535>        Default( 22 )
            max     = number    # required  <1-65535>        Default( 22 )
        }
        protocol    = string    # required  <tcp/udp/"">     Default( "" )
        ethertype   = string    # required  <IPv4/IPv6>      Default( IPv4 )
        direction   = string    # optional  <ingress/egress> Default( ingress )
        prefix      = string    # optional  <0.0.0.0/0>      Default( 0.0.0.0/0 )
    }
]
```

- network
```hcl
network = {
    net_name        = string    # required  <any>            Default( terraform )
    extnet_name     = string    # required  <any>            Default( external )
    cidr_block      = string    # optional  <0.0.0.0/0>      Default( 192.168.0.0/24 )
    dns_nameservers = list      # optional  <["0.0.0.0"]>    Default( ["8.8.8.8"] )
}
```

- user
```hcl
user = {
    name            = string    # required  <any>            Default( terraform )
    hashed_password = string    # required  <password hash>  Default( $6$any_salt$hwzTmq... )
}
```
---
<br />

## Usage
- Create a file called `terraform.tfvars`
- Populate the file with variables to override defaults. Example:
```hcl
instances = [
    { name = "example-instance-1" },
    { name = "example-instance-2" },
    { name = "example-instance-3" }
]

secgroup_rules = [
    {
    port_range = { min = 22, max = 22 },
    protocol   = "tcp",
    ethertype  = "IPv4"
    },
    {
    port_range = { min = 80, max = 80 },
    protocol   = "tcp",
    ethertype  = "IPv4"
    },
    {
    port_range = { min = 443, max = 443 },
    protocol   = "tcp",
    ethertype  = "IPv4"
    }
]

network = {
    net_name    = "network-1",
    extnet_name = "ext-net-1"
}

user = {
    name            = "user-1",
    hashed_password = "$6$wgdfghbfghgf$3P5TkbGDQ8py4xQFVSqKiT.s6BIQ0kGoIk66vZvY/T/Ijr9XZFCRLa7KB7/bslj/IUVETnfdBMrZknpXHgcqF/"
}
```
- In the [provider.tf](provider.tf) file, define the credentials for connecting to openstack. Example:
```hcl
provider "openstack" {
    insecure          = true
    auth_url          = https://openstack.domain.ru:5000/v3/
    user_name         = os-user
    password          = os-password
    user_domain_name  = default
    region            = region
}
```
- Init the terraform workspace
```hcl
terraform init
```
---
<br />

## Requirements
[Terraform](https://releases.hashicorp.com/terraform) >= [v1.5.4](https://releases.hashicorp.com/terraform/1.5.4/) <br />
Providers:
- [openstack](https://registry.terraform.io/providers/terraform-provider-openstack/openstack) >= [3.0.0](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/3.0.0)
- [template](https://registry.terraform.io/providers/hashicorp/template/latest) >= [2.2.0](https://registry.terraform.io/providers/hashicorp/template/2.2.0)
- [null](https://registry.terraform.io/providers/hashicorp/null) >= [3.2.3](https://registry.terraform.io/providers/hashicorp/null/3.2.3)
- [local](https://registry.terraform.io/providers/hashicorp/local) >= [2.5.2](https://registry.terraform.io/providers/hashicorp/local/2.5.2)
