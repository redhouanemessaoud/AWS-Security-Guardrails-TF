variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_filename" {
  description = "The path to the Lambda deployment package"
  type        = string
}

variable "lambda_handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs14.x"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for encrypting environment variables"
  type        = string
}

variable "dead_letter_queue_arn" {
  description = "The ARN of the SQS queue or SNS topic for the dead letter queue"
  type        = string
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this Lambda function"
  type        = number
  default     = -1
}

variable "subnet_ids" {
  description = "The list of subnet IDs for VPC configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "The list of security group IDs for VPC configuration"
  type        = list(string)
}

variable "signing_profile_version_arns" {
  description = "The list of ARNs of the signing profile versions for code signing"
  type        = list(string)
}

variable "invoking_service_principal" {
  description = "The service principal of the AWS service invoking the function"
  type        = string
}

variable "invoking_service_source_arn" {
  description = "The source ARN of the invoking service"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to store in AWS Secrets Manager"
  type        = map(string)
  default     = {}
}