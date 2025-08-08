# ELK stack monitoring


## Initially configuring and installing the ELK stack - proper planning and architectural design


### Define your goals and Use cases
	- what do you need to observe

		- system level monitoring
		- log aggregation from RHEL, KVM, Kubernetes
		- alerting on failures, restarts, anomalies
		- visual dashboard for capacity and health

	- this affects
		- what data sources to collect from
		- which beats or integrations are needed
		- data volume expectations

### Estimate Data Ingestion and Storage Requirements

	- Estimation factors
		- number of hosts, VMs, containers
		- logs per host/containter
		- retention period
		- average log line size

		- Elasticsearch adds 20-30% indexing overhead
		- plan for compression

### Plan Index and Shard Strategy

	- use index per source or index per service type patterns
		- system logs
		- KVM
		- Kubernetes
		- Metrics

	- Shard Best Practices
		- shard size 10-50 GB
		- start with 1-2 primary shards per index, 1 replica
		- avoid small shard - 100s of shards < 1GB
	- Configure Index Lifecycle Management (ILM)
		- Hot -> Warm -> Delete phases
			- example: 7 days hot, 23 days warm, delete on day 30

### Choose the Right Topology

	- Small/Medium deployments
		- single node for Elasticsearch, Logstash, Kibana
		- 4-8 CPU cores, 16-32 GB RAM

	- For Production / High Volume
		- dedicated nodes
			- 3+ Elasticsearch master/data nodes
			- 1-2 Logstash nodes
			- 1 Kibana node
		- hot/warm architecture for data retention

### Plan log and Metric Ingestion
	- RHEL Logs - filebeat - system, auth, journal logs
	- Metrics - metricbeat - host cpu, disk, memory
	- KVM - Filebeat - QEMU, libvirt logs

	- can optionally insert Logstash between Beats and Elasticsearch for:
		- log parsing
		- enrichment
		- routing logs to multiple outputs

### Design Parsing and Structuring
	- ensure consistent structured fields
		- host.name, vm.name, kubernetes.pod.name, log.level, log.source, service.name

	- filebeat modules for automatic parsing
	- custom ingest pipelines - Elasticsearch or Logstash for custom logs

### Plan for Security
	- enable TLS between nodes
	- use basic Auth or interate with LDAP
	- Use RBAC in Kibana
	- harden exposed ports - 9200, 5601 or place behind a reverse proxy

### Monitoring the ELK Stack Itself
	- monitor heap usage, GC, node uptime, indexing rates
	- set up alerts for slow queries or disk thresholds
		- install metricbeat on each ELK component to send internal metrics to a dedicated monitoring-* index

## Summary and Checklist

	1. Observability Goals
	2. Ingestion volume
	3. Choose topology
	4. Install Components
	5. Configure indices and shards
	6. Set up ingestion agents
	7. Parse and structure logs
	8. Secure the stack
	9. Monitor ELK itself