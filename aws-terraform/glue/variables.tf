variable "security_configuration_name" {
  description = "Name of the Glue security configuration"
  type        = string
}

variable "cloudwatch_kms_key_arn" {
  description = "ARN of the KMS key for CloudWatch encryption"
  type        = string
}

variable "job_bookmarks_kms_key_arn" {
  description = "ARN of the KMS key for job bookmarks encryption"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN of the KMS key for S3 encryption"
  type        = string
}

variable "dev_endpoint_name" {
  description = "Name of the Glue development endpoint"
  type        = string
}

variable "dev_endpoint_role_arn" {
  description = "ARN of the IAM role for the development endpoint"
  type        = string
}

variable "dev_endpoint_security_group_ids" {
  description = "List of security group IDs for the development endpoint"
  type        = list(string)
}

variable "dev_endpoint_subnet_id" {
  description = "Subnet ID for the development endpoint"
  type        = string
}

variable "dev_endpoint_log_group_name" {
  description = "Name of the CloudWatch log group for the development endpoint"
  type        = string
}

variable "data_catalog_kms_key_arn" {
  description = "ARN of the KMS key for Data Catalog encryption"
  type        = string
}

variable "connection_name" {
  description = "Name of the Glue connection"
  type        = string
}

variable "jdbc_connection_url" {
  description = "JDBC connection URL"
  type        = string
}

variable "jdbc_username" {
  description = "JDBC connection username"
  type        = string
}

variable "jdbc_password" {
  description = "JDBC connection password"
  type        = string
  sensitive   = true
}

variable "connection_security_group_ids" {
  description = "List of security group IDs for the Glue connection"
  type        = list(string)
}

variable "connection_subnet_id" {
  description = "Subnet ID for the Glue connection"
  type        = string
}

variable "connection_availability_zone" {
  description = "Availability zone for the Glue connection"
  type        = string
}

variable "catalog_id" {
  description = "ID of the Data Catalog"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "allowed_principals" {
  description = "List of allowed AWS principals for Data Catalog access"
  type        = list(string)
}

variable "job_name" {
  description = "Name of the Glue job"
  type        = string
}

variable "job_role_arn" {
  description = "ARN of the IAM role for the Glue job"
  type        = string
}

variable "glue_version" {
  description = "Version of Glue to use"
  type        = string
  default     = "3.0"
}

variable "script_location" {
  description = "S3 location of the Glue job script"
  type        = string
}

variable "python_version" {
  description = "Python version for the Glue job"
  type        = string
  default     = "3"
}

variable "job_log_group" {
  description = "Name of the CloudWatch log group for the Glue job"
  type        = string
}

variable "spark_event_logs_path" {
  description = "S3 path for Spark event logs"
  type        = string
}

variable "temp_dir" {
  description = "Temporary directory for Glue job"
  type        = string
}

variable "max_concurrent_runs" {
  description = "Maximum number of concurrent runs for the Glue job"
  type        = number
  default     = 1
}

variable "max_retries" {
  description = "Maximum number of retries for the Glue job"
  type        = number
  default     = 0
}

variable "timeout" {
  description = "Timeout for the Glue job in minutes"
  type        = number
  default     = 2880
}

variable "worker_type" {
  description = "Type of worker for the Glue job"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Number of workers for the Glue job"
  type        = number
  default     = 2
}

variable "notify_delay_after" {
  description = "Delay after which to send notification for job status"
  type        = number
  default     = 1800
}