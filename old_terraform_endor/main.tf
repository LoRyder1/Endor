# Define data source for the customized RHEL image
data "libvirt_volume" "rhel_base_image" {
  pool = "default" # Assuming default pool for the base image
  name = split("/", var.rhel_cloud_image_path)[length(split("/", var.rhel_cloud_image_path)) - 1]
}

# --- Kubernetes Control Plane Nodes ---
resource "libvirt_volume" "k8s_control_plane_disk" {
  count  = var.control_plane_count
  name   = "k8s-control-plane-${count.index + 1}-disk"
  pool   = "vm_data_vg" # Use the LVM volume group
  source = var.rhel_cloud_image_path
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024 # 50 GB
}

resource "libvirt_cloudinit_disk" "k8s_control_plane_cloudinit" {
  count  = var.control_plane_count
  name   = "k8s-control-plane-${count.index + 1}-cloudinit.iso"
  pool   = "default" # Can be in default pool or dedicated pool for ISOs
  user_data = templatefile("${path.module}/templates/cloud-init-config.yaml.tftpl", {
    hostname = "k8s-control-plane-${count.index + 1}"
    # Only a single network interface for these nodes
    eth0_ip    = "${var.vm_network_prefix}.${100 + count.index}" # e.g., 10.10.10.100, .101, .102
    eth0_gateway = "${var.vm_network_prefix}.1" # Assuming your br1 gateway
    eth1_ip    = "" # Not used
    eth1_gateway = "" # Not used
    nameservers = ["8.8.8.8", "8.8.4.4"]
    ssh_public_key = file(var.ssh_public_key)
  })
}

resource "libvirt_domain" "k8s_control_plane" {
  count  = var.control_plane_count
  name   = "k8s-control-plane-${count.index + 1}"
  memory = 8192 # 8 GB
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.k8s_control_plane_cloudinit[count.index].id

  network_interface {
    network_name   = var.vm_bridge_name # Connected to br1 (VM Network)
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k8s_control_plane_disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# --- Kubernetes Worker Nodes ---
resource "libvirt_volume" "k8s_worker_disk" {
  count  = var.worker_count
  name   = "k8s-worker-${count.index + 1}-disk"
  pool   = "vm_data_vg"
  source = var.rhel_cloud_image_path
  format = "qcow2"
  size   = 100 * 1024 * 1024 * 1024 # 100 GB
}

resource "libvirt_cloudinit_disk" "k8s_worker_cloudinit" {
  count  = var.worker_count
  name   = "k8s-worker-${count.index + 1}-cloudinit.iso"
  pool   = "default"
  user_data = templatefile("${path.module}/templates/cloud-init-config.yaml.tftpl", {
    hostname = "k8s-worker-${count.index + 1}"
    eth0_ip    = "${var.vm_network_prefix}.${110 + count.index}" # e.g., 10.10.10.110, .111, .112
    eth0_gateway = "${var.vm_network_prefix}.1"
    eth1_ip    = "" # Not used
    eth1_gateway = "" # Not used
    nameservers = ["8.8.8.8", "8.8.4.4"]
    ssh_public_key = file(var.ssh_public_key)
  })
}

resource "libvirt_domain" "k8s_worker" {
  count  = var.worker_count
  name   = "k8s-worker-${count.index + 1}"
  memory = 12288 # 12 GB
  vcpu   = 6

  cloudinit = libvirt_cloudinit_disk.k8s_worker_cloudinit[count.index].id

  network_interface {
    network_name   = var.vm_bridge_name # Connected to br1 (VM Network)
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k8s_worker_disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# --- Load Balancer Nodes ---
resource "libvirt_volume" "lb_disk" {
  count  = var.load_balancer_count
  name   = "lb-${count.index + 1}-disk"
  pool   = "vm_data_vg"
  source = var.rhel_cloud_image_path
  format = "qcow2"
  size   = 30 * 1024 * 1024 * 1024 # 30 GB
}

resource "libvirt_cloudinit_disk" "lb_cloudinit" {
  count  = var.load_balancer_count
  name   = "lb-${count.index + 1}-cloudinit.iso"
  pool   = "default"
  user_data = templatefile("${path.module}/templates/cloud-init-config.yaml.tftpl", {
    hostname = "lb-${count.index + 1}"
    eth0_ip    = "${var.vm_network_prefix}.${120 + count.index}" # e.g., 10.10.10.120, .121
    eth0_gateway = "${var.vm_network_prefix}.1"
    eth1_ip    = "" # Not used
    eth1_gateway = "" # Not used
    nameservers = ["8.8.8.8", "8.8.4.4"]
    ssh_public_key = file(var.ssh_public_key)
  })
}

resource "libvirt_domain" "lb" {
  count  = var.load_balancer_count
  name   = "lb-${count.index + 1}"
  memory = 4096 # 4 GB
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.lb_cloudinit[count.index].id

  network_interface {
    network_name   = var.vm_bridge_name # Connected to br1 (VM Network)
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.lb_disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# --- Monitoring/Jumpbox Node ---
resource "libvirt_volume" "monitoring_disk" {
  count  = var.monitoring_node_count
  name   = "monitoring-${count.index + 1}-disk"
  pool   = "vm_data_vg"
  source = var.rhel_cloud_image_path
  format = "qcow2"
  size   = 80 * 1024 * 1024 * 1024 # 80 GB
}

resource "libvirt_cloudinit_disk" "monitoring_cloudinit" {
  count  = var.monitoring_node_count
  name   = "monitoring-${count.index + 1}-cloudinit.iso"
  pool   = "default"
  user_data = templatefile("${path.module}/templates/cloud-init-config.yaml.tftpl", {
    hostname = "monitoring-${count.index + 1}"
    eth0_ip    = "${var.management_network_prefix}.130" # Management IP on br0
    eth0_gateway = "${var.management_network_prefix}.1" # Assuming br0 gateway
    eth1_ip    = "${var.vm_network_prefix}.130" # VM Network IP on br1
    eth1_gateway = "${var.vm_network_prefix}.1" # Assuming br1 gateway
    nameservers = ["8.8.8.8", "8.8.4.4"]
    ssh_public_key = file(var.ssh_public_key)
  })
}

resource "libvirt_domain" "monitoring" {
  count  = var.monitoring_node_count
  name   = "monitoring-${count.index + 1}"
  memory = 8192 # 8 GB
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.monitoring_cloudinit[count.index].id

  network_interface {
    network_name   = var.management_bridge_name # Connected to br0 (Management Network)
    wait_for_lease = true
  }

  network_interface {
    network_name   = var.vm_bridge_name # Connected to br1 (VM Network)
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.monitoring_disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# --- Database Nodes ---
resource "libvirt_volume" "db_disk" {
  count  = var.database_count
  name   = "db-${count.index + 1}-disk"
  pool   = "vm_data_vg"
  source = var.rhel_cloud_image_path
  format = "qcow2"
  size   = 100 * 1024 * 1024 * 1024 # 100 GB
}

resource "libvirt_cloudinit_disk" "db_cloudinit" {
  count  = var.database_count
  name   = "db-${count.index + 1}-cloudinit.iso"
  pool   = "default"
  user_data = templatefile("${path.module}/templates/cloud-init-config.yaml.tftpl", {
    hostname = "db-${count.index + 1}"
    eth0_ip    = "${var.vm_network_prefix}.${140 + count.index}" # e.g., 10.10.10.140, .141
    eth0_gateway = "${var.vm_network_prefix}.1"
    eth1_ip    = "" # Not used
    eth1_gateway = "" # Not used
    nameservers = ["8.8.8.8", "8.8.4.4"]
    ssh_public_key = file(var.ssh_public_key)
  })
}

resource "libvirt_domain" "db" {
  count  = var.database_count
  name   = "db-${count.index + 1}"
  memory = 8192 # 8 GB
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.db_cloudinit[count.index].id

  network_interface {
    network_name   = var.vm_bridge_name # Connected to br1 (VM Network)
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}