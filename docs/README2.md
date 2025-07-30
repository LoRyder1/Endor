## Phase 2 - Provisioning KVM Vms with Terraform & Configuring with Ansible

### RHEL Host for for Terraform execution

1. install terrafom on host OS and ansible playbook

Manual Steps for Host OS

1. SH Key Generation
	- ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa.pub
	- the public key will be injected into VMs

2. Base QCOW2 Image prep
	- download RHEL Cloud image
	- move to libvirt image pool
	- sudo mkdir -p /var/lib/libvirt/images
	- sudo mv /path/to/image /var/lib/libvirt/images/xxx
	- install libguestfs-tools for virt-customize
		- sudo dnf install -y libguestfs-tools
	- Customize the Base Image
		- inject your SSH public key for root
		- ensure cloud-init services are enabled, as Terraform will use cloud-init for initial VM config
			- sudo virt-customize -a /var/lib/libvirt/images/rhel.qcow2 \
			- --ssh-inject root:file:/root/.ssh/id_rsa.pub \
			- --run-command 'systemctl enable cloud-init cloud-init-local cloud-config cloud-final' \
			- --selinux-relabel
			
### Ansible playbook for RHEL Host OS Terraform Preparation

- automate next step on kvm-host-01
- pre-reqs
	- must be able to ssh into kvm-host-01 from management machine
	- kvm-host-01 needs network connectivity to download packages and cloud image
	
- create inventory file
- create host_terraform_prep.yml file
