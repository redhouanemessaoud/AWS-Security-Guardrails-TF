variable "environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  type        = string
}

variable "application_name" {
  description = "Name of the Elastic Beanstalk application"
  type        = string
}

variable "solution_stack_name" {
  description = "Solution stack name for the Elastic Beanstalk environment"
  type        = string
}

variable "managed_actions_start_time" {
  description = "Start time for managed actions"
  type        = string
  default     = "Tue:10:00"
}

variable "vpc_id" {
  description = "ID of the VPC to use for the Elastic Beanstalk environment"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to use for the Elastic Beanstalk environment"
  type        = list(string)
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile to use for EC2 instances"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume for EC2 instances"
  type        = number
  default     = 20
}

variable "security_group_id" {
  description = "ID of the security group to use for EC2 instances"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables for the Elastic Beanstalk environment"
  type        = map(string)
  default     = {}
}

variable "autoscaling_min_size" {
  description = "Minimum number of instances in the auto scaling group"
  type        = number
  default     = 1
}

variable "autoscaling_max_size" {
  description = "Maximum number of instances in the auto scaling group"
  type        = number
  default     = 4
}

variable "rds_engine_version" {
  description = "Version of the RDS engine to use"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the Elastic Beanstalk environment"
  type        = string
}

variable "eb_bucket_name" {
  description = "Name of the S3 bucket for Elastic Beanstalk application versions"
  type        = string
}