variable "kvm_host_ssh_user" {
  description = "The SSH user for the KVM host"
  type        = string
  default     = "your_ssh_user"
}

variable "kvm_host_address" {
  description = "The IP address of the KVM host"
  type        = string
  default     = "192.168.1.10"
}

variable "vm_network_bridge" {
  description = "The KVM network bridge for the VMs"
  type        = string
  default     = "br1"
}

variable "cloud_image_path" {
  description = "Path to the customized RHEL cloud image"
  type        = string
  default     = "/var/lib/libvirt/images/rhel-9.qcow2"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}