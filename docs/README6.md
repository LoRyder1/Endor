# Resource allocation of vCPUs, RAM, Disk size

## Physical Server Requirements - minimums
	 - Control plane server: 8 vCPU, 16 GB RAM, 200 GB storage
	 - Worker servers: 16 vCPU, 32 GB RAM, 500 GB storage
	 - Load Balancer servers: 4 vCPU, 8 GB RAM, 100 GB storage

### Control Plane server - 3 servers
1. CPU
	- 2 vCPU for hypervisor overhead
	- the rest for CP
	- etcd is CPU intensive, API server handles many requests
2. RAM
	- 2-4 GB for hypervisor overhead
	- the rest for CP
	- etcd memory usage grows with cluster size, API server caching
3. Storage
	- Reserve 30 GB for hypervisor
	- Root disk - 50-100 GB - OS, container images, logs
	- etcd disk - 50 GB SSD/NVMe
	- container storage - 50 GB
	
### Worker Nodes - 2 servers
1. CPU
	- 2 vCPU for hypervisor
	- the rest for worker node
	- maximum compute for application workloads
2. RAM
	- 2-4 GB for hypervisor
	- 28-30 GB per VM
	- applications need substantial memory, kubelet overhead
3. Storage
	- 50 GB for hypervisor
	- root disk - 100GB
	- container/pod storage: 300 GB 
	- local storage for pods: 100 GB

### Load Balancer Nodes - 2 servers
1. CPU
	- 2 vCPU for hypervisor
	- the rest for Load Balancer
	- HAProxy is lightweight but needs responsiveness
2. RAM
	- 2 GB for hypervisor
	- the rest for load balancer
	- HAProxy has minimal memory requirements
3. Storage
	- 30 GB for hypervisor
	- Root - 50 GB
	- Logs - 20 GB
	
View you system's NUMA topology - numactl --hardware lscpu
Pin CPU's and NUMA awareness
- start by letting OS handle it automatically
- consider manual pinning only if profiling shows cross-NUMA memory access is a bottleneck in your specific workload

### Storage Performance Optimization

1. etcd storage: SSD/NVMe with low latency
2. Container runtime: separate disk from OS when possible
3. VM disk format: qcow2 with preallocation

## Full stack will look like

Kubernetess Pods
Container Runtime
Guest OS
KVM Hypervisor
RHEL - Host OS
Physical Hardware