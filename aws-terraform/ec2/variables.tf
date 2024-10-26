variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t3.micro"  # Use the latest generation instance type as default
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the instance"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with the instance"
  type        = string
}

variable "kms_key_id" {
  description = "The KMS key ID to use for EBS volume encryption"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the instance"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "enable_termination_protection" {
  description = "Enable termination protection for the instance"
  type        = bool
  default     = true
}

variable "use_dedicated_instance" {
  description = "Use a dedicated instance"
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "security_group_id" {
  description = "The ID of the security group to add ingress rules to"
  type        = string
}

variable "flow_log_role_arn" {
  description = "The ARN of the IAM role for VPC flow logs"
  type        = string
}

variable "flow_log_destination" {
  description = "The ARN of the destination for VPC flow logs"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for flow logs"
  type        = string
}

variable "ssm_service_role_arn" {
  description = "The ARN of the IAM role for SSM to perform maintenance tasks"
  type        = string
}