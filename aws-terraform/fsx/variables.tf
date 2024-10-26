variable "storage_capacity" {
  description = "The storage capacity of the file system in GiB"
  type        = number
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the file system"
  type        = list(string)
}

variable "deployment_type" {
  description = "The deployment type of the file system"
  type        = string
  default     = "PERSISTENT_1"
}

variable "storage_type" {
  description = "The storage type for the file system"
  type        = string
  default     = "SSD"
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the file system"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the file system"
  type        = map(string)
  default     = {}
}

variable "automatic_backup_retention_days" {
  description = "The number of days to retain automatic backups"
  type        = number
  default     = 30
}

variable "import_path" {
  description = "The import path for FSx for Lustre"
  type        = string
  default     = null
}

variable "export_path" {
  description = "The export path for FSx for Lustre"
  type        = string
  default     = null
}

variable "imported_file_chunk_size" {
  description = "The imported file chunk size in MiB"
  type        = number
  default     = 1024
}

variable "storage_capacity_quota_gib" {
  description = "The amount of storage quota in GiB"
  type        = number
  default     = null
}

variable "throughput_capacity" {
  description = "The throughput capacity of the file system in MB/s"
  type        = number
}

variable "active_directory_id" {
  description = "The ID of the AWS Directory Service directory to join"
  type        = string
}

variable "weekly_maintenance_start_time" {
  description = "The preferred start time for weekly maintenance"
  type        = string
  default     = "1:00:00"
}

variable "storage_virtual_machine_name" {
  description = "The name of the storage virtual machine"
  type        = string
}

variable "storage_capacity_threshold" {
  description = "The threshold for storage capacity alarm in percentage"
  type        = number
  default     = 80
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to notify for alarms"
  type        = string
}