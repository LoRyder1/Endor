# Endor
K8s cluster




Router Domain name
SkyRiver

Server -  MCU
Host OS - rocky

Skyriver - Endor, forest, KVM role or type, KVM guest name

5. Resource planning CPUs, RAM, and disk space
6. leave some overhead for Host OS
7. persistent storage: hyper-converged storage - Rook.io with Ceph

Host OS - minimal install - CLI only
RHEL KVM - Kubernetes cluster - minimal installs

VMs:
cp x3
wrker x 3
loadbalancer x2
persistent storage - on workers use Rook - Ceph
Monitoring/Jumpbox x1
Database VMs - x2

1 physical server
16 cores, - 32 logical processors or threads
CPU w/ 32 logical processors,  128GB RAM, 2TB virtual disk
 

High level architecture plan for a physical server with Linux Host OS, guest VMs KVM, Kubernetes cluster
3 node control plane, 3 worker nodes, 2 load balancers, persistent storage, 2 database VMs
How to allocate vCPUs, RAM, and storage for Host OS, KVM guest VMs, Kubernetes cluster, persistent storage, database integration


Example Project:
Give Refined High-Level Architecture Plan (with Storage Detail, vCPUs, RAM)
1 physical server, 1 CPU - 32 logical processors, 128GB RAM, 2TB total of virtual disk in RAID 10, 2 NICs. Hardware inventory is final.
General outline of project - 
1. RHEL - Host OS - VM on Server. 
2. using RHEL - KVM and Kubernetes Cluster VMs:
	- 3 control plane nodes
	- 3 worker nodes
	- 2 load balancers
	- for persistent storage use Rook and Ceph
	- 1 Monitoring/Jumpbox node
	- 2 Database RHEL VMs
	
How to allocate vCPUs, RAM, and storage for Host OS, KVM guest VMs, Kubernetes cluster, persistent storage, database integration


Use Terraform for IaC and Ansible for configuration management

rocky difference between cloud image and regular image