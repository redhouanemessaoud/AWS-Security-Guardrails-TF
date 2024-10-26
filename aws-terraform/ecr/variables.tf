variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for ECR encryption"
  type        = string
}

variable "allowed_pull_principals" {
  description = "List of AWS principals allowed to pull images"
  type        = list(string)
  default     = []
}

variable "allowed_push_principals" {
  description = "List of AWS principals allowed to push images"
  type        = list(string)
  default     = []
}

variable "replication_region" {
  description = "AWS region for ECR replication"
  type        = string
  default     = ""
}

variable "replication_registry_id" {
  description = "Registry ID for ECR replication"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}

variable "pull_through_cache_prefix" {
  description = "Repository prefix for pull through cache"
  type        = string
  default     = ""
}

variable "upstream_registry_url" {
  description = "URL of the upstream registry for pull through cache"
  type        = string
  default     = ""
}