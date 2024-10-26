variable "workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting Athena query results and databases"
  type        = string
}

variable "query_output_location" {
  description = "S3 location for storing Athena query results"
  type        = string
}

variable "query_result_reuse_ttl" {
  description = "Time to live (in seconds) for cached query results"
  type        = number
  default     = 3600 # 1 hour
}

variable "query_timeout" {
  description = "Query timeout in seconds"
  type        = number
  default     = 1800 # 30 minutes
}

variable "log_retention_days" {
  description = "Number of days to retain Athena logs"
  type        = number
  default     = 90
}

variable "log_group_kms_key_arn" {
  description = "ARN of the KMS key for encrypting CloudWatch log group"
  type        = string
}

variable "database_name" {
  description = "Name of the Athena database"
  type        = string
}

variable "catalog_id" {
  description = "ID of the Data Catalog in which the database resides"
  type        = string
  default     = null
}