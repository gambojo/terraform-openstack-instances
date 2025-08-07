# ${timestamp}
---
all:
  vars:
    ansible_user: ${username}
    ansible_ssh_private_key_file: "${ssh_key}"
  hosts:
%{ for name, instance in instances ~}
    ${name}:
      ansible_host: ${instance.external_ip}
      private_ip: ${instance.internal_ip}
%{ endfor ~}
