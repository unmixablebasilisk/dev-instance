resource "openstack_compute_instance_v2" "dev_instance" {
  name            = var.instance_name
  flavor_name     = var.flavor_name
  key_pair        = "${var.instance_name}-key"
  security_groups = ["default"]
  network {
    name = var.network_name
  }
  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    source_type           = "image"
    volume_size           = var.volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  provisioner "remote-exec" {
    # inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
    inline = ["echo Done!"]

    connection {
      host        = openstack_compute_instance_v2.dev_instance.access_ip_v4
      type        = "ssh"
      user        = "centos"
      private_key = file(var.private_key)
    }
  }

  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -i '${openstack_compute_instance_v2.dev_instance.access_ip_v4},' --private-key ${var.private_key} playbook.yml"
  # }
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.instance_name}-key"
  public_key = file(var.public_key)
}

output "instance_ip_address" {
  value = openstack_compute_instance_v2.dev_instance.access_ip_v4
}

resource "openstack_blockstorage_volume_v3" "volume_1" {
  name        = "${var.instance_name}-vol"
  description = "dev volume for ${openstack_compute_instance_v2.dev_instance.name}"
  size        = 100
}

resource "openstack_compute_volume_attach_v2" "volume_attach_1" {
  instance_id = openstack_compute_instance_v2.dev_instance.id
  volume_id   = openstack_blockstorage_volume_v3.volume_1.id

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -i '${openstack_compute_instance_v2.dev_instance.access_ip_v4},' --private-key ${var.private_key} playbook.yml"
  }
}

resource "local_file" "ssh_config" {
  content  = <<EOT
Host *
  ServerAliveInterval 10
  ServerAliveCountMax 10
Host bastion
  Hostname bastion-host-name
  User ${var.user_id}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  Port 22
  LogLevel Quiet
  IdentityFile ${var.privkey_path}
Host dev
  Hostname ${openstack_compute_instance_v2.dev_instance.access_ip_v4}
  User centos
  IdentityFile ${var.privkey_path}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh -W %h:%p bastion
EOT
  filename = "config"
}
