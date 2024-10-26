variable "environment_name" {
  description = "Name of the MWAA environment"
  type        = string
}

variable "airflow_version" {
  description = "Version of Apache Airflow to use"
  type        = string
  default     = "2.5.1"  # Use the latest stable version
}

variable "environment_class" {
  description = "Environment class for the MWAA environment"
  type        = string
  default     = "mw1.small"
}

variable "max_workers" {
  description = "Maximum number of workers for the MWAA environment"
  type        = number
  default     = 10
}

variable "min_workers" {
  description = "Minimum number of workers for the MWAA environment"
  type        = number
  default     = 1
}

variable "dag_s3_path" {
  description = "S3 path for DAGs"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM execution role for MWAA"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the S3 bucket containing DAGs and supporting files"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the MWAA environment"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the MWAA environment"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for MWAA environment encryption"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the MWAA environment"
  type        = map(string)
  default     = {}
}

variable "dag_s3_bucket" {
  description = "Name of the S3 bucket containing DAGs"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with MWAA"
  type        = string
}