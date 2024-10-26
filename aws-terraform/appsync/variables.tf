variable "api_name" {
  description = "Name of the AppSync API"
  type        = string
}

variable "authentication_type" {
  description = "Authentication type for the AppSync API"
  type        = string
  default     = "AWS_IAM"
}

variable "schema_file_path" {
  description = "Path to the GraphQL schema file"
  type        = string
}

variable "api_caching_behavior" {
  description = "Caching behavior of the AppSync API"
  type        = string
  default     = "PER_RESOLVER_CACHING"
}

variable "cache_type" {
  description = "Cache type for AppSync API"
  type        = string
  default     = "SMALL"
}

variable "cache_size" {
  description = "Cache size for AppSync API"
  type        = number
  default     = 1
}

variable "cache_ttl" {
  description = "Cache TTL for AppSync API (in seconds)"
  type        = number
  default     = 3600
}

variable "cloudwatch_logs_role_arn" {
  description = "ARN of the IAM role for CloudWatch logs"
  type        = string
}

variable "max_requests_per_second" {
  description = "Maximum requests per second for API throttling"
  type        = number
  default     = 1000
}

variable "max_burst" {
  description = "Maximum burst for API throttling"
  type        = number
  default     = 2000
}