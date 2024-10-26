variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "ID of the AMI to use for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for the instances"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch resources in"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to associate with the ASG"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "on_demand_percentage" {
  description = "Percentage of On-Demand instances in the ASG"
  type        = number
  default     = 100
}

variable "ssm_instance_profile_name" {
  description = "Name of the IAM instance profile for Systems Manager"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}