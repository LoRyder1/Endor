output "k8s_control_plane_ips" {
  description = "IP addresses of Kubernetes Control Plane Nodes (VM Network)"
  value       = [for domain in libvirt_domain.k8s_control_plane : domain.network_interface[0].addresses[0]]
}

output "k8s_worker_ips" {
  description = "IP addresses of Kubernetes Worker Nodes (VM Network)"
  value       = [for domain in libvirt_domain.k8s_worker : domain.network_interface[0].addresses[0]]
}

output "load_balancer_ips" {
  description = "IP addresses of Load Balancer Nodes (VM Network)"
  value       = [for domain in libvirt_domain.lb : domain.network_interface[0].addresses[0]]
}

output "monitoring_management_ip" {
  description = "Management IP address of Monitoring/Jumpbox Node (Management Network)"
  value       = libvirt_domain.monitoring[0].network_interface[0].addresses[0]
}

output "monitoring_vm_ip" {
  description = "VM Network IP address of Monitoring/Jumpbox Node (VM Network)"
  value       = libvirt_domain.monitoring[0].network_interface[1].addresses[0]
}

output "database_ips" {
  description = "IP addresses of Database Nodes (VM Network)"
  value       = [for domain in libvirt_domain.db : domain.network_interface[0].addresses[0]]
}