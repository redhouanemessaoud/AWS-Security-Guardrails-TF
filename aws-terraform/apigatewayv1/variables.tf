variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "Secure API Gateway"
}

variable "vpc_endpoint_ids" {
  description = "List of VPC Endpoint IDs for private API Gateway"
  type        = list(string)
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "prod"
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for API Gateway logs"
  type        = string
}

variable "log_format" {
  description = "Format of the access logs"
  type        = string
  default     = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
}

variable "enable_cache" {
  description = "Enable API Gateway caching"
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "The size of the cache cluster for the stage, if enabled"
  type        = string
  default     = "0.5"
}

variable "cache_ttl" {
  description = "Time to live (in seconds) for cached responses"
  type        = number
  default     = 300
}

variable "waf_acl_arn" {
  description = "ARN of the WAF ACL to associate with the API Gateway stage"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "authorizer_lambda_arn" {
  description = "ARN of the Lambda function for custom authorizer"
  type        = string
}

variable "authorizer_role_arn" {
  description = "ARN of the IAM role for the custom authorizer"
  type        = string
}

variable "quota_limit" {
  description = "The maximum number of requests that can be made in a given time period"
  type        = number
  default     = 1000
}

variable "quota_offset" {
  description = "The number of requests subtracted from the given limit in the initial time period"
  type        = number
  default     = 0
}

variable "quota_period" {
  description = "The time period in which the limit applies"
  type        = string
  default     = "WEEK"
}

variable "throttle_burst_limit" {
  description = "The API request burst limit"
  type        = number
  default     = 5
}

variable "throttle_rate_limit" {
  description = "The API request steady-state rate limit"
  type        = number
  default     = 10
}

variable "domain_name" {
  description = "The domain name for the API Gateway custom domain"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the custom domain"
  type        = string
}

variable "truststore_uri" {
  description = "The S3 URI of the truststore for mutual TLS authentication"
  type        = string
}

variable "truststore_version" {
  description = "The version of the truststore"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for API Gateway resource policy"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "lambda_invoke_arn" {
  description = "The ARN to be used for invoking the Lambda function from API Gateway"
  type        = string
}