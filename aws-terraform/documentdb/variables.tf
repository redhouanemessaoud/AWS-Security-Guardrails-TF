variable "cluster_identifier" {
  description = "The identifier for the DocumentDB cluster"
  type        = string
}

variable "engine_version" {
  description = "The engine version for DocumentDB"
  type        = string
  default     = "4.0.0"
}

variable "master_username" {
  description = "The master username for the DocumentDB cluster"
  type        = string
}

variable "master_password" {
  description = "The master password for the DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "02:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the cluster should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the cluster"
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of instances to create in the cluster"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "The instance class to use for cluster instances"
  type        = string
  default     = "db.r5.large"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}