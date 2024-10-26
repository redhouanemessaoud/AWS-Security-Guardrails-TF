variable "domain_name" {
  description = "Name of the Elasticsearch domain"
  type        = string
}

variable "elasticsearch_version" {
  description = "Version of Elasticsearch to deploy"
  type        = string
  default     = "7.10"
}

variable "instance_type" {
  description = "Instance type of data nodes in the cluster"
  type        = string
  default     = "r5.large.elasticsearch"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 3
}

variable "dedicated_master_type" {
  description = "Instance type of the dedicated master nodes"
  type        = string
  default     = "c5.large.elasticsearch"
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy the Elasticsearch domain in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to apply to the Elasticsearch domain"
  type        = list(string)
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GB)"
  type        = number
  default     = 100
}

variable "kms_key_id" {
  description = "KMS key ID to encrypt the Elasticsearch domain with"
  type        = string
}

variable "master_user_arn" {
  description = "ARN of the IAM user to be set as master user for the Elasticsearch domain"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group to publish Elasticsearch logs to"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges to access the Elasticsearch domain"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_cross_cluster_search" {
  description = "Enable cross-cluster search"
  type        = bool
  default     = false
}

variable "cross_cluster_search_connection_alias" {
  description = "Alias for the cross-cluster search connection"
  type        = string
  default     = ""
}

variable "target_domain_name" {
  description = "Name of the target Elasticsearch domain for cross-cluster search"
  type        = string
  default     = ""
}

variable "target_domain_endpoint" {
  description = "Endpoint of the target Elasticsearch domain for cross-cluster search"
  type        = string
  default     = ""
}

variable "target_domain_region" {
  description = "Region of the target Elasticsearch domain for cross-cluster search"
  type        = string
  default     = ""
}