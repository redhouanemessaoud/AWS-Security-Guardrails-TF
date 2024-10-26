variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "Version of OpenSearch to deploy"
  type        = string
  default     = "OpenSearch_2.5"
}

variable "instance_type" {
  description = "Instance type for data nodes in the cluster"
  type        = string
  default     = "r6g.large.search"
}

variable "instance_count" {
  description = "Number of data nodes in the cluster"
  type        = number
  default     = 3
}

variable "dedicated_master_type" {
  description = "Instance type for dedicated master nodes"
  type        = string
  default     = "r6g.large.search"
}

variable "warm_enabled" {
  description = "Whether to enable warm storage"
  type        = bool
  default     = false
}

variable "warm_type" {
  description = "Instance type for warm nodes"
  type        = string
  default     = "ultrawarm1.medium.search"
}

variable "warm_count" {
  description = "Number of warm nodes"
  type        = number
  default     = 2
}

variable "cold_storage_enabled" {
  description = "Whether to enable cold storage"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the OpenSearch domain to use"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to apply to the OpenSearch domain"
  type        = list(string)
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GB)"
  type        = number
  default     = 100
}

variable "ebs_volume_type" {
  description = "Type of EBS volumes attached to data nodes"
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS key ID to encrypt the OpenSearch domain with"
  type        = string
}

variable "internal_user_database_enabled" {
  description = "Whether to enable the internal user database"
  type        = bool
  default     = true
}

variable "master_user_name" {
  description = "Main user's username"
  type        = string
}

variable "master_user_password" {
  description = "Main user's password"
  type        = string
  sensitive   = true
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group to which log types are published"
  type        = string
}

variable "automated_snapshot_start_hour" {
  description = "Hour during which the service takes an automated daily snapshot of the indices in the domain"
  type        = number
  default     = 0
}

variable "custom_endpoint" {
  description = "Custom endpoint for the OpenSearch domain"
  type        = string
}

variable "custom_endpoint_certificate_arn" {
  description = "ACM certificate ARN for custom endpoint"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses or CIDR blocks"
  type        = list(string)
  default     = []
}