variable "cluster_name" {
  description = "Name of the MemoryDB cluster"
  type        = string
}

variable "node_type" {
  description = "Node type for the MemoryDB cluster"
  type        = string
}

variable "num_shards" {
  description = "Number of shards in the MemoryDB cluster"
  type        = number
  default     = 1
}

variable "num_replicas_per_shard" {
  description = "Number of replica nodes in each shard"
  type        = number
  default     = 2
}

variable "subnet_group_name" {
  description = "Name of the subnet group to use for the MemoryDB cluster"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the MemoryDB cluster"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption"
  type        = string
}

variable "engine_version" {
  description = "Version of the MemoryDB engine to use"
  type        = string
  default     = "6.2"
}

variable "snapshot_retention_limit" {
  description = "Number of days for which MemoryDB retains automatic snapshots"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily time range during which automated backups are created"
  type        = string
  default     = "05:00-09:00"
}

variable "maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:23:00-mon:01:30"
}

variable "port" {
  description = "Port number on which the MemoryDB cluster accepts connections"
  type        = number
  default     = 6379
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for event notifications"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}