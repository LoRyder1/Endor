# Cluster Configuration
control_plane_nodes = 3
worker_nodes        = 3
database_nodes      = 2

# IP Address Configuration
control_plane_ips = ["10.10.10.20", "10.10.10.21", "10.10.10.22"]
worker_ips        = ["10.10.10.30", "10.10.10.31", "10.10.10.32"]
load_balancer_ips = ["10.10.10.10", "10.10.10.11"]
database_ips      = ["10.10.10.40", "10.10.10.41"]
jumpbox_ip        = "10.10.10.12"

# VM Resource Configuration (Revised)
lb_vcpus         = 1
lb_ram           = 4096
cp_vcpus         = 2
cp_ram           = 8192
worker_vcpus     = 4
worker_ram       = 16384
jumpbox_vcpus    = 2
jumpbox_ram      = 8192
db_vcpus         = 3
db_ram           = 16384