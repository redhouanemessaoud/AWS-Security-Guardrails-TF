variable "cluster_identifier" {
  description = "The identifier for the Neptune cluster"
  type        = string
}

variable "engine_version" {
  description = "The engine version for Neptune"
  type        = string
  default     = "1.2.1.0"
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 35
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "02:00-03:00"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the cluster"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for encryption"
  type        = string
}

variable "snapshot_identifier" {
  description = "The identifier for the DB snapshot or DB cluster snapshot to restore from"
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "List of Availability Zones for the cluster"
  type        = list(string)
}

variable "min_capacity" {
  description = "The minimum capacity for the Neptune cluster"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "The maximum capacity for the Neptune cluster"
  type        = number
  default     = 16
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Neptune"
  type        = list(string)
}

variable "neptune_security_group_id" {
  description = "ID of the security group for Neptune"
  type        = string
}

variable "cpu_utilization_threshold" {
  description = "The threshold for CPU utilization alarm"
  type        = number
  default     = 80
}

variable "failed_login_threshold" {
  description = "The threshold for failed login attempts alarm"
  type        = number
  default     = 5
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms"
  type        = string
}