# ${timestamp}
---
all:
  vars:
    ansible_user: ${username}
    ansible_ssh_private_key_file: "${ssh_key}"
    ansible_host_key_checking: False
  hosts:
%{ for name, instance in instances ~}
    ${name}:
      ansible_host: ${instance.external_ip}
      internal_ip: ${instance.internal_ip}
%{ endfor ~}
