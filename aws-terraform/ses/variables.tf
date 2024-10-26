variable "enable_ses_identity_policy" {
  description = "Enable SES identity policy"
  type        = bool
  default     = true
}

variable "ses_identity_arn" {
  description = "ARN of the SES identity"
  type        = string
}

variable "allowed_principals" {
  description = "List of AWS principals allowed to use the SES identity"
  type        = list(string)
  default     = []
}

variable "configuration_set_name" {
  description = "Name of the SES configuration set"
  type        = string
  default     = "secure-ses-config-set"
}

variable "domain_name" {
  description = "Domain name for SES identity"
  type        = string
}

variable "enable_sending_authorization" {
  description = "Enable SES sending authorization policy"
  type        = bool
  default     = true
}

variable "authorized_senders" {
  description = "List of AWS principals authorized to send emails"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for SES feedback notifications"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for content filtering"
  type        = string
}