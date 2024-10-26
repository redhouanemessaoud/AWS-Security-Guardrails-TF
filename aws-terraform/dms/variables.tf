variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "replication_instance_class" {
  description = "The compute and memory capacity of the replication instance"
  type        = string
  default     = "dms.t3.micro"
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the replication instance"
  type        = list(string)
}

variable "replication_subnet_group_id" {
  description = "ID of the replication subnet group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "secrets_manager_role_arn" {
  description = "ARN of the IAM role that allows DMS to access Secrets Manager"
  type        = string
}

variable "secrets_manager_arn" {
  description = "ARN of the secret in Secrets Manager containing the endpoint credentials"
  type        = string
}

variable "cdc_start_time" {
  description = "The start time for CDC (Change Data Capture) operation"
  type        = string
  default     = null
}