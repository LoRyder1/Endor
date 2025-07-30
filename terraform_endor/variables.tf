variable "rhel_cloud_image_path" {
  description = "Path to the customized RHEL cloud image qcow2 file."
  type        = string
  default     = "/var/lib/libvirt/images/rhel-cloud-base.qcow2" # As per Ansible playbook2 outcome
}

variable "vm_data_vg_path" {
  description = "Path to the LVM volume group for VM disk provisioning."
  type        = string
  default     = "/dev/vm_data_vg" # As per Ansible playbook1 outcome
}

variable "vm_bridge_name" {
  description = "Name of the KVM bridge for the VM network."
  type        = string
  default     = "br1" # As per Ansible playbook1 outcome
}

variable "management_bridge_name" {
  description = "Name of the KVM bridge for the management network (br0)."
  type        = string
  default     = "br0"
}

variable "control_plane_count" {
  description = "Number of Kubernetes control plane nodes."
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes."
  type        = number
  default     = 3
}

variable "load_balancer_count" {
  description = "Number of load balancer nodes."
  type        = number
  default     = 2
}

variable "database_count" {
  description = "Number of database nodes."
  type        = number
  default     = 2
}

variable "monitoring_node_count" {
  description = "Number of monitoring/jumpbox nodes."
  type        = number
  default     = 1
}

variable "vm_network_prefix" {
  description = "The first three octets of the VM network (e.g., 10.10.10)."
  type        = string
  default     = "10.10.10"
}

variable "management_network_prefix" {
  description = "The first three octets of the management network (e.g., 192.168.1)."
  type        = string
  default     = "192.168.1"
}

variable "ssh_public_key" {
  description = "Your SSH public key for root access to VMs."
  type        = string
  default     = "~/.ssh/id_rsa.pub" # Or specify the actual path to your public key
}