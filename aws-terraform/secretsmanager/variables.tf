variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

variable "secret_description" {
  description = "Description of the Secrets Manager secret"
  type        = string
  default     = "Managed by Terraform"
}

variable "kms_key_id" {
  description = "ARN or ID of the AWS KMS customer master key (CMK) to be used to encrypt the secret values in the versions stored in this secret"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the secret"
  type        = map(string)
  default     = {}
}

variable "secret_policy" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function that can rotate the secret"
  type        = string
}

variable "rotation_days" {
  description = "Number of days between automatic scheduled rotations of the secret"
  type        = number
  default     = 30
}

variable "db_credentials" {
  description = "Map of database credentials to be stored in the secret"
  type        = map(string)
  default     = {}
}