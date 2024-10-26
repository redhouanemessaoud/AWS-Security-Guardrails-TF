variable "replication_group_id" {
  description = "The ID of the ElastiCache replication group"
  type        = string
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "The number of cache clusters (primary and replicas) this replication group will have"
  type        = number
  default     = 2
}

variable "parameter_group_name" {
  description = "The name of the parameter group to associate with this replication group"
  type        = string
}

variable "engine_version" {
  description = "The version number of the cache engine"
  type        = string
  default     = "6.x"
}

variable "kms_key_id" {
  description = "The ARN of the key that you wish to use if encrypting at rest"
  type        = string
}

variable "auth_token" {
  description = "The password used to access a password protected server"
  type        = string
  sensitive   = true
}

variable "snapshot_retention_limit" {
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster"
  type        = string
  default     = "05:00-09:00"
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the Security Group to associate with the ElastiCache cluster"
  type        = string
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "cpu_threshold" {
  description = "The CPU utilization threshold for the CloudWatch alarm"
  type        = number
  default     = 75
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to send CloudWatch alarms"
  type        = string
}