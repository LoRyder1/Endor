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





July 30, 2025

```
Example Project:

High-Level Architecture Plan (with Storage Detail, vCPUs, RAM)

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

allocate vCPUs, RAM, and storage for Host OS, KVM guest VMs, Kubernetes cluster, persistent storage, database integration

Use Terraform for IaC and Ansible for configuration management



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

Ansible script already run for configuration of RHEL Host once manually installed

Ansible script for RHEL Host for Terraform configuration already run

outcomes:

playbook 1 outcome:

1. fully updated

2. time synchronized

3. firewall configured w/ necessary rules for SSH, libvirt, and the KVM bridge

4. KVM and libvirt services enabled and running

5. br1 bridge configured - enslaving your second physical NIC, ready for VMs

6. vm_data_vg - LVM Volume Group created on you unallocated RAID 10 space, ready for terraform to create logical volumes for your VMs

7. default virbr0 NAT network disabled

Playblook2 outcome:

1. ssh public key available for virt-customize

2. libguestfs-tools installed

3. RHEL cloud image downloaded and customized with SSH key and cloud-init

4. terraform installed in /usr/local/bin



What are next steps in terms of using Terraform to provision infrastructure for Kubnernetes cluster, give detailed and specific scripts and directory layout

```

Output scripts again with IP addressing scheme for network and VM ip address scheme that needs to be configured:

Management Network br0

192.168.1-30

- RHEL Host

- Jumpbox Monitoring VM eth0

- Server OOB

VM Network Bridge

- 10.10.10.0/24 for VMs - RHEL host, lb, database, K8s

K8s cluster internal network - pod network

- 10.42.0.0/16

Services network

- kubernetes services

- 10.43.0.0/16

```
Terraform done

What are the next steps of configuration management using Ansible?
```



















