#cloud-config
users:
  - name: ${user_name}
    passwd: ${user_password}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - '${public_key}'

runcmd:
  - mkdir -p /home/${user_name}/.ssh
  - chown -R ${user_name}:${user_name} /home/${user_name}
  - chmod 700 /home/${user_name}/.ssh
  - chmod 600 /home/${user_name}/.ssh/authorized_keys
