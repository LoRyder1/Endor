# Simple setup

## RHEL and KVM Setup
RHEL - KVM - K8


1. install RHEL 9
2. install kvm and libvirt
3. configure Network Bridge
	- br0 - to allow VMs to connect to your physical network
	- create a bridge and add your physical network interface to it
## Create RHEL 9 VMs - one for control plane, one for worker node
	- use virt-install to create the two VMs connecting them to the br0 network bridge
	- use a cloud image to install
## VM Configuration
	- after installation
	- configure static IP address, hostname, add other VM's hostname to /etc/hosts file for name resolution
	- disable swap
	- disable SELinux for simpolicity
	- open firewall ports on each VM for Kubernetes communication
## Kubernetes installtion with kubeadm
	- install container runtime like containerd on both the control plane and worker VMs
	- install kubeadm, kubelet, and kubectl - install core kubernetes tools on both VMs
	- initialize the control plane - on control plane run kubeadm init
	- provide the Pod network CIDR and IP address the API server will adervtise on
	- configure kubectl: after initialization, kubeadm will give you commands to set up the kubectl config file for your user
	- configure kubectl - after initialization, kubeadm will give you commands to set up the kubectl config files for your user
7. Install a POd Network - CNI
	- cluster not functional untill you install CNI plugin - simple option is Flannel
8. Join the Worker Node - kubeadm init command outputs a kubeadm join command

## Load Balancer (MetalLB)

1. Install MetalLB - on the control plane VM, install MetalLB
2. Configure a Pool of Ip addresses: create a ConfigMap to define the IP address range MetalLB will use
	- range must be outside your DHCP pool but within the same subnet