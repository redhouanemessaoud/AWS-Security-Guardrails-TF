variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone"
  type        = string
}

variable "enable_query_logging" {
  description = "Enable query logging for Route 53"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for Route 53 query logging"
  type        = string
  default     = ""
}

variable "enable_dnssec" {
  description = "Enable DNSSEC for the hosted zone"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for DNSSEC signing"
  type        = string
  default     = ""
}

variable "key_signing_key_name" {
  description = "Name of the key-signing key for DNSSEC"
  type        = string
  default     = "route53-dnssec-key"
}

variable "is_private_zone" {
  description = "Whether the hosted zone is private"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
  default     = ""
}

variable "enable_health_check" {
  description = "Enable Route 53 health check"
  type        = bool
  default     = true
}

variable "health_check_fqdn" {
  description = "FQDN for the health check"
  type        = string
  default     = ""
}

variable "health_check_port" {
  description = "Port for the health check"
  type        = number
  default     = 80
}

variable "health_check_type" {
  description = "Type of health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_resource_path" {
  description = "Resource path for the health check"
  type        = string
  default     = "/"
}

variable "health_check_failure_threshold" {
  description = "Failure threshold for the health check"
  type        = number
  default     = 3
}

variable "health_check_request_interval" {
  description = "Request interval for the health check"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}