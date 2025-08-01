# Next Steps

## Ansible Inventory:
Generate a dynamic or static Ansible inventory file that lists all the newly provisioned VMs with their respective IP addresses.

## Kubernetes Configuration Playbook:
Run an Ansible playbook that configures the Kubernetes cluster.

Install necessary packages (containerd, kubeadm, kubelet, kubectl).

Initialize the control plane nodes with kubeadm init.

Join the worker nodes to the cluster using the kubeadm join command.

Install a Pod network (e.g., Calico or Flannel).

## Rook/Ceph Playbook:
Run an Ansible playbook to deploy Rook and Ceph for persistent storage.

Deploy the Rook operator.

Create a Ceph cluster.

Create storage classes for Kubernetes.

## Database Configuration Playbook:
Run an Ansible playbook to configure the database VMs.

Install and configure the chosen database software (e.g., PostgreSQL, MySQL).

Set up replication and high availability as required.

## Load Balancer Configuration Playbook:
Configure the load balancers (e.g., using HAProxy or Keepalived) to distribute traffic to the Kubernetes control plane and services.

## Monitoring Playbook:
Use Ansible to install and configure monitoring tools (e.g., Prometheus and Grafana) on the Jumpbox/Monitoring VM.


### Kubernetes Config playbook
	- inventory.ini - is ready
	- ansible_user - has passwordless sudo configured, as per the cloud-init script
	
	- running playbook 
		- ansible-playbook - inventory2.ini kubernetes-setup.yml

### Rook and Ceph

	- ansible-playbook -i inventory2.ini roock-seph-setup.yml

### Database Config playbook
	- ansible-playbook -i inventory2.ini postgres-setup.yml

### Load Balancer Configuration playbook
	- ansible-playbook -i inventory2.ini loadbalancer-setup.yml

### Monitoring playbook:
	- ansible-playbook -i inventory.ini monitoring-setup.yml


## Verify the Deployed Infrastructure

	1. Kubernetes Cluster Verification
		- kubectl get nodes
			- verify all nodes are in 'Ready' state
		- kubectl get pods --all-namespaces
			- verify all pods in the 'kube-system' namespace are running
		- kubectl get pds -n kube-system -l k8s-app=calico-node
			- verify the Calico pod network is healthy
	2. Load balancer verification
		- curl -k https://10.10.10.10:6443/version
	3. Rook/Ceph Verification
		- kubectl get pods -n rook-seph
		- kubectl -n rook-ceph get cephcluster my-ceph-cluster -o jsonpath='{.status.ceph.health}'
		- kubectl get storageclass
	4. PostgreSQL Database Verification
		- sudo -u postgres psql
		- SELECT pid, state, client_addr FROM pg_stat_replication
	5. Monitoring Stack Verification
		- Prometheus UI - http://10.10.10.12:9090
		- Grafana UI - http://10.10.10.12:3000