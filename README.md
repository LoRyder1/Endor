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

------------------------------------------------------------------------------------------
<!-- 
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
Use Terraform for IaC and Ansible for configuration management -->

* Integrate Satellite or alternative in separate physical/VM - resource intensive
	- Lifecycle Management - maybe use Foreman/katello

# Refined High-Level Architecture Plan

- 1 physical server
- CPU - 32 logical processors - 16 cores with hyperthreading
- RAM - 128 GB
- Virtual Disk - RAID 10 - 2 TB
	- RAID 1 - data is first mirrored, create sets of mirrored pairs
	- RAID 0 - Striping across mirrored pairs - data striped across pairs
- Physical NICs - 2

* Infrastructure as code: Terraform for VM provisioning and network setup
* Ansible for OS configuration and application deployment


## Phase 1:

RHEL 9 w/o Network Scripts use Network Manager

1. Host Operating System - RHEL - KVM Hypervisor - Installation
	- purpose serve as virtualization host for all guest VMs using KVM
	- vCPUs - 4
	- RAM - 8 GB
	- Storage - 100 GB

	a) hardware virtualization check
		- grep -E 'vmx|svm' /proc/cpuinfo
	b) create bootable media w/ minimal install Rocky 9 - CLI only 
	c) Custom or Manual Partitioning
		- scheme
			- /boot - 2GB xfs
			- / - 50GB
			- /var - 20 GB
			- swap - 12 GB
	d) Software
		- minimal install
		- select virtualization host 
			- will install qemu-kvm, libvirt, virt-install, virt-manager
	e) hostname
		- kvm-host-01
	f) Networking
		- NIC1 - Management
			- connect auto
		- NIC2 - Internal/VM Traffic
			- do not enable connect automatically
	g) timezone
	h) root password, user creation
	i) security policy - STIGS

2. Post-Installation
	a) system update
		- sudo dnf update -y
		- sudo reboot
	b) verify kvm installation
		- sudo systemctl status libvirtd
		- lsmod | grep kvm
	c) Network Bridge Configuration
		- NIC1 - good
		- NIC2 - VM Network Bridge
		- nmcli device status
		- create bridge connetion
			- sudo nmcli connection add type bridge con-name br1 ifname br1 ipv4.method disabled ipv6.method disabled
		- add second NIC as a slave to bridge
			- sudo nmcli connection add type ethernet con-name br1-slave-xxxx ifname xxxx master br1
		- bring up bridge
			- sudo nmcli connection up br1
			- sudo nmcli connection up br1-slave-xxx
		- verify bridge connection
			- nmcli connection show
			- nmcli device status
			- ip a show br1
	d) Firewall
		- firewall configuration
			- sudo firewall-cmd --permanent --add-service=ssh
			- sudo firewall-cmd --permanent --add-service=libvirt
			- sudo firewall-cmd --permanent --add-port=16509/tcp
			- sudo firewall-cmd --permanent --zone=trusted --add-interface=br1
			- sudo firewall-cmd --reload
			
		- Storage setup for VMs - use LVM
			- sudo fdisk -l
			- sudo pvcreate /dev/xxx
			- sudo vgcreate vm_data_vg /dev/xxx
		- disable default libvirt NAT - recommended for bridge only setup
			- sudo virsh net-destroy default
			- sudo virsh net-autostart --disable default
			- sudo systemctl enable libvirtd --now
			

## Ansible: Automating configuration of RHEL Host once installed:

Prereq
	1. ansible control node
	2. SSH Access - ansible user
	3. inventory file configured for host
	4. Physical NIC Names
	5. LVM setup - leave majority of 2TB RAID 10 disk as unallocated space or as a raw partition /dev/sda4 - you can convert to a Physical Volume

Project Structure

ansible_endor/
├── inventory.ini
├── ansible.cfg
├── playbooks/ 
|	└── kvm_host_setup.yml
└── roles/
	└── kvm_host/
		|── tasks/
		│   ├── main.yml
        │   ├── system_hardening.yml
        │   ├── packages.yml
        │   ├── networking.yml
        │   ├── kvm_config.yml
        │   └── storage.yml
        ├── handlers/
        │   └── main.yml
        └── defaults/
            └── main.yml


inventory.ini

[kvm_hosts]
kvm-host-01 ansible_host=KVM_HOST_IP ansible_user=youruser ansible_become_method=sudo ansible_python_interpreter=/usr/bin/python3

[all:vars]
 - define variables common to all hosts, or specific kvm_hosts group
 - this is the physical NIC that will be used for the KVM bridge
 kvm_bridge_physical_nic enp2s0
 kvm_bridge_name: br1
 kvm_storage_pv_device: /dev/sda4
 kvm_storage_vg_name: vm_data_vg


------------------------------------------------------------------------
* is there a way to automate post-installation with scripts or tool?
 - yes Ansiblize it!


























































