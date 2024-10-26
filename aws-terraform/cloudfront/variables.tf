variable "distribution_comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "s3_origin_domain_name" {
  description = "Domain name of the S3 bucket origin"
  type        = string
}

variable "s3_origin_id" {
  description = "ID for the S3 origin"
  type        = string
}

variable "secondary_s3_origin_id" {
  description = "ID for the secondary S3 origin (for failover)"
  type        = string
}

variable "geo_restriction_type" {
  description = "Type of geo restriction (whitelist or blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for SSL/TLS"
  type        = string
}

variable "waf_web_acl_id" {
  description = "ID of the AWS WAF WebACL to associate with the distribution"
  type        = string
}

variable "log_bucket" {
  description = "S3 bucket for CloudFront access logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}
}

variable "field_level_encryption_public_key_id" {
  description = "ID of the public key for field-level encryption"
  type        = string
}