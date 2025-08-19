# RHEL, KVM, Kubernetes setup

## Prereq
	- physical servers have RHEL installed
	- KVM and libvirt are enabled for virtualization
	- Static Ips
	- Proper DNS or /etc/hosts entries for all nodes
	- firewalld rules opened for Kubernetes components
	- SELinux is permissive/enforcing
	- SSH access between nodes for cluster setup

## Install and Configure KVM on All Servers
	- qemu, libvirt, virt-install, bridge-utils, virt-manager
	- configure a bridged network so VMs get LAN-accessible IPs

## Create Virtual Machines
	- virt-install
	- 


## Docker discussion

	- Docker is little brother to Kubernetes
	- Cloud with EKS would be the right solution
	- STIGG docker containers - TINES and Alchemy

## Prepare the OS on Each Node

	- vim, wget, curl, net-tools, bind-utils, iproute-tc
	- sudo setenforce 0
	- SELINUX- permissive /etc/selinux/config
	- sudo modprobe br_netfilter
	- disable swap
		- sudo swapoff -a
		- sudo sed -i '/swap/d' /etc/fstab

## Install Container Runtime

	- containerd

## Install Kubernetes Binaries

## Initialize the Cluster
	- kubeadm init
	- configure for the root user
	