variable "node_name" {}
variable "node_ip" {}
variable "node_vcpus" {}
variable "node_ram" {}
variable "disk_size" {}
variable "cloud_image_path" {}
variable "vm_network_bridge" {}
variable "ssh_public_key" {}

resource "libvirt_volume" "node_disk" {
  pool   = "vm_data_vg"
  name   = "${var.node_name}-disk"
  size   = var.disk_size * 1024 * 1024 * 1024
  source = var.cloud_image_path
}

resource "libvirt_domain" "node" {
  name   = var.node_name
  memory = var.node_ram
  vcpu   = var.node_vcpus

  disk {
    volume_id = libvirt_volume.node_disk.id
  }

  network_interface {
    bridge = var.vm_network_bridge
    addresses = [var.node_ip]
  }

  cloudinit = {
    user_data = templatefile("${path.module}/cloud-init-template.yaml", {
      hostname = var.node_name
      ip_address = var.node_ip
      ssh_public_key = var.ssh_public_key
    })
  }
}