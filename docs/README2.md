## Phase 2 - Provisioning KVM Vms with Terraform & Configuring with Ansible

### RHEL Host for for Terraform execution

1. install terrafom on host OS and ansible playbook

Manual Steps for Host OS

1. SSH Key Generation
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
3. User creation
	- create myself, ansible, terraform
			
### Ansible playbook for RHEL Host OS Terraform Preparation

- automate next step on kvm-host-01
- pre-reqs
	- must be able to ssh into kvm-host-01 from management machine
	- kvm-host-01 needs network connectivity to download packages and cloud image
	
- create inventory file
- create host_terraform_prep.yml file

Running playblook

	- execute the playbook
	- ansible-playbook -i inventory.ini playbooks/host_terraform_prep.yml
	- provide ssh password if prompted

Playblook outcome:
1. ssh public key available for virt-customize
2. libguestfs-tools installed
3. RHEL cloud image downloaded and customized with SSH key and cloud-init
4. terraform installed in /usr/local/bin


## Terraform for KVM provisioning

### Phase 3

Directory Layout
```
.
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output definitions
│   ├── providers.tf            # Provider configuration (libvirt)
│   ├── versions.tf             # Terraform and provider version constraints
│   ├── instances.tf            # VM instance definitions (control plane, worker, etc.)
│   ├── network.tf              # Network configurations (if any specific to Terraform)
│   ├── storage.tf              # Storage definitions (libvirt volumes)
│   └── templates/
│       └── cloud-init-config.yaml.tftpl # Cloud-init template
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini           # Ansible inventory for post-Terraform configuration
│   ├── playbooks/
│   │   ├── kubernetes-cluster.yml
│   │   ├── database-setup.yml
│   │   └── monitoring-setup.yml
│   └── roles/                  # Ansible roles for specific configurations
└── README.md
```


Important notes on terraform provisioning 

1. Host Network Configuration
	- ensure br0 is properly set with static IP - 192.168.1.10 and it serves as the gateway/ap for management network
	- ensure br1 is configured as a bridge - without an IP on the host if only used for VMs and is ready for the 10.10.10.0/24 VM network

2. Gateways
	- cloud-init-config.yaml.tftpl includes gateway4 for both eth0 and eth1 if both are configured
	- may want to set a gateway on eth0 or handle this through Ansible post provisioning

3. IP ranges 
	- IP ranges for VMs are set starting from .100 for control plnes, .110 for workers

4. Firewall
	- ensure your RHEL Host firewall allows traffic on br0 for management access to the host and Jumpbox and br1 for VM traffic. 

5. Ansible inventory
	- update ansible/inventory/hosts.ini using new IP addresses obtained from terraform output
	- for jumpbox connect to it via 192.168.1.130 - management IP for Ansible operations
	
Ready fro terraform init, terraform plan, terraform apply


1. Navigate to terraform directory
	- terraform init
2. validate
	- terraform validate
3. preview changes
	- terraform plan
4. provision infrastructure 
	- terraform apply
5. Verify
	- list running VMs on KVM host
		- virsh list --all
	- chekc ip addr
		- terraform output k8s_control_plane_ips
		- terraform output k8s_worker_ips
		- terraform output load_balancer_ips
		- terraform output monitoring_management_ip
		- terraform output monitoring_vm_ip
		- terraform output database_ips
	- attempt to ssh into VMs
		- ssh root@192.168.1.130
		- ssh root@10.10.10.100

6. Prepare for Ansible - post terraform
	- Generate your ansible/inventory/hosts.ini file
	- use terraform output commands to populate file





























