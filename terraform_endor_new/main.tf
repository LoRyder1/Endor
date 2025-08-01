terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://${var.kvm_host_ssh_user}@${var.kvm_host_address}/system"
}

# Data source to read the SSH public key
data "local_file" "ssh_key" {
  filename = var.ssh_public_key_path
}

# Main for Jumpbox/Monitoring VM
resource "libvirt_volume" "jumpbox_disk" {
  pool   = "vm_data_vg"
  name   = "jumpbox-disk"
  size   = 60 * 1024 * 1024 * 1024 # 60 GB
  source = var.cloud_image_path
}

resource "libvirt_domain" "jumpbox" {
  name   = "jumpbox"
  memory = var.jumpbox_ram
  vcpu   = var.jumpbox_vcpus

  disk {
    volume_id = libvirt_volume.jumpbox_disk.id
  }

  network_interface {
    bridge = var.vm_network_bridge
    addresses = [var.jumpbox_ip]
  }

  network_interface {
    bridge = "br0"
    addresses = ["192.168.1.11"]
  }

  cloudinit = {
    user_data = templatefile("${path.module}/cloud-init-template.yaml", {
      hostname = "jumpbox"
      ip_address = var.jumpbox_ip
      ssh_public_key = data.local_file.ssh_key.content
    })
  }
}


# Call Kubernetes module for control plane nodes
module "control_plane_nodes" {
  source           = "./modules/kubernetes-node"
  count            = var.control_plane_nodes
  node_name        = "k8s-cp-${count.index + 1}"
  node_ip          = var.control_plane_ips[count.index]
  node_vcpus       = var.cp_vcpus
  node_ram         = var.cp_ram
  disk_size        = 60
  cloud_image_path = var.cloud_image_path
  vm_network_bridge = var.vm_network_bridge
  ssh_public_key = data.local_file.ssh_key.content
}

# Call Kubernetes module for worker nodes
module "worker_nodes" {
  source           = "./modules/kubernetes-node"
  count            = var.worker_nodes
  node_name        = "k8s-worker-${count.index + 1}"
  node_ip          = var.worker_ips[count.index]
  node_vcpus       = var.worker_vcpus
  node_ram         = var.worker_ram
  disk_size        = 100
  cloud_image_path = var.cloud_image_path
  vm_network_bridge = var.vm_network_bridge
  ssh_public_key = data.local_file.ssh_key.content
}

# Call Kubernetes module for load balancers
module "load_balancers" {
  source           = "./modules/kubernetes-node"
  count            = 2
  node_name        = "lb-${count.index + 1}"
  node_ip          = var.load_balancer_ips[count.index]
  node_vcpus       = var.lb_vcpus
  node_ram         = var.lb_ram
  disk_size        = 40
  cloud_image_path = var.cloud_image_path
  vm_network_bridge = var.vm_network_bridge
  ssh_public_key = data.local_file.ssh_key.content
}

# Call Database module for database VMs
module "database_nodes" {
  source           = "./modules/database-node"
  count            = var.database_nodes
  node_name        = "database-${count.index + 1}"
  node_ip          = var.database_ips[count.index]
  node_vcpus       = var.db_vcpus
  node_ram         = var.db_ram
  disk_size        = 150
  cloud_image_path = var.cloud_image_path
  vm_network_bridge = var.vm_network_bridge
  ssh_public_key = data.local_file.ssh_key.content
}