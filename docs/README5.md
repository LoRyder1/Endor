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

# Index and Shard Strategy

## Decide Indexing Strategy based on Use Case

	- Data type
	- Component
	- Time
## Plan Number and Size of Shards

	- Example
		- 20 GB/day of system logs from 10 servers
		- you keep logs for 30 days
		- 1 primary and 1 replica per daily index
		Then
			- 30 indices x 1 primary shard = 30 primary shards
			- 30 indices x 1 replica = 30 replica
			- Total - 60 shards -> very manageable

## Use Index Templates and ILM Policies

	- create index templates
	- ILM
		- roll over indices
		- move to warm/cold nodes
		- delete old indices

## Align Query Patterns with Index Design
	
	- avoid querying too many indices at once
	- use index aliases

## Use Aliases and Rollovers for Log Streams

	- use filebeat or logstash to write to logs-system-wrie and let ILM manage rollovers

## Monitor your shard health
	
	- watch for:
		- unassigned shards
		- frequent shard relocations
		- high heap pressure on Elasticsearch nodes


# Splunk Architecture and Design

## Estimate Log Volume
## Plan Splunk Architecture

	- FOr clustered architecture
		- large production environment
			1. Deployment Server
			2. 2+ INdexers - distributed
			3. 1 Search Head
			4. 1 License Master
			5. 1 Heavy Forwarder

## Index and Data Management Strategy
	
	- split by log type or data source for clarity and lifecycle control
		- os logs, kvm_logs, k8s_logs, metrics, security_logs

## Retention and Sizing
	
	- define retention per index using froenTimePeriodInSecs
		- use summary indexing or data models with acceleration for long-term analytics

## Ingestion and Data Collection Strategy

	- Universal Forwarder - lightweight, preferred for endpoints
	- Heavy Forwarder - for parsing and filtering data before ingestion
	- API and HEC (HTTP Event Collector) - ideal for cloud-native or container logs
		- Examples
			- RHEL - UF
			- KVM logs - UF
			- Kubernetes - HEC + Fluentd/Fluent Bit
			- Metrics - Collectd + UF or OpenTelemetry 

## Configuration Best Practices

	- Input and Output
		- use inputs.conf to define what logs to collect
		- use props.conf and transforms.conf for field extraction and sourcetype normalization
			- example specific sourcetypes
				- rhel:syslog
				- kvm:qemu
				- k8s:pod
				- metrics:host

## Security and Access Control

	- Plan for RBAC and secure communication
		- TLS between forwarders and indexers
		- use hardened inputs - restric source IPs
		- configure roles and access via authorize.conf

## High Availability and Scaling

	- Indexers
		- use indexer clustering with replication factor = 2
		- set search factor = 2 for redundancy
	- Search Heads
		- use search head cluster (3+ nodes)
		- requires deployer node
	- Storage
		- SSD for hot/warm buckets
		- NFS or object storage for cold/frozen

## Monitoring Splunk Itself

	- install Splunk Monitoring Console
		- monitor indexing queues
		- view search concurrency
		- track forwarder connection health
		- identify skipped or blocked data

### Example Splunk Topology

	- 3 physical servers - indexers
	- 1 physical server - search head
	- 1 physical server - Control plane server
		- roles combined
			- cluster, license master, deployment server, monitoring console

