variable "api_name" {
  description = "Name of the API Gateway V2 API"
  type        = string
}

variable "protocol_type" {
  description = "The API protocol type (HTTP or WEBSOCKET)"
  type        = string
  default     = "HTTP"
}

variable "stage_name" {
  description = "Name of the API Gateway V2 stage"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for access logging"
  type        = string
}

variable "access_log_format" {
  description = "Format of the access logs"
  type        = string
  default     = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
}

variable "throttling_burst_limit" {
  description = "Throttling burst limit"
  type        = number
  default     = 5000
}

variable "throttling_rate_limit" {
  description = "Throttling rate limit"
  type        = number
  default     = 10000
}

variable "authorizer_type" {
  description = "Type of authorizer to use (JWT, REQUEST, or TOKEN)"
  type        = string
  default     = "JWT"
}

variable "identity_sources" {
  description = "Identity sources for the authorizer"
  type        = list(string)
  default     = ["$request.header.Authorization"]
}

variable "authorizer_name" {
  description = "Name of the authorizer"
  type        = string
}

variable "jwt_audience" {
  description = "Audience for JWT authorizer"
  type        = list(string)
}

variable "jwt_issuer" {
  description = "Issuer for JWT authorizer"
  type        = string
}

variable "route_key" {
  description = "Route key for the API Gateway V2 route"
  type        = string
}

variable "route_authorization_type" {
  description = "Authorization type for the route (NONE, JWT, AWS_IAM, or CUSTOM)"
  type        = string
  default     = "JWT"
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the API Gateway"
  type        = string
}

variable "api_key_name" {
  description = "Name of the API key"
  type        = string
}

variable "cors_allow_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "cors_allow_methods" {
  description = "List of allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
}

variable "cors_max_age" {
  description = "Maximum age for CORS preflight cache"
  type        = number
  default     = 300
}

variable "custom_domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  type        = string
}

variable "model_name" {
  description = "Name of the request validation model"
  type        = string
}

variable "model_schema" {
  description = "JSON schema for the request validation model"
  type        = string
}

variable "integration_type" {
  description = "Type of integration (AWS, AWS_PROXY, HTTP, HTTP_PROXY, MOCK)"
  type        = string
  default     = "AWS_PROXY"
}

variable "connection_type" {
  description = "Type of connection for the integration (INTERNET or VPC_LINK)"
  type        = string
  default     = "INTERNET"
}

variable "integration_method" {
  description = "Integration HTTP method"
  type        = string
  default     = "POST"
}

variable "integration_uri" {
  description = "URI for the integration (e.g., Lambda function ARN)"
  type        = string
}

variable "integration_timeout" {
  description = "Timeout for the integration in milliseconds"
  type        = number
  default     = 29000
}

variable "cache_cluster_size" {
  description = "Size of the cache cluster (0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, or 237)"
  type        = string
  default     = "0.5"
}

variable "stage_variables" {
  description = "Map of stage variables"
  type        = map(string)
  default     = {}
}