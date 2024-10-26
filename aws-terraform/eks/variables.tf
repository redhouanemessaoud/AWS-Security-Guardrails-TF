variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.24"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "ID of the security group for the EKS cluster"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting Kubernetes secrets"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "IPv4 CIDR block for Kubernetes services"
  type        = string
  default     = "172.20.0.0/16"
}

variable "node_role_arn" {
  description = "ARN of the IAM role for EKS node groups"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS node groups"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ec2_ssh_key" {
  description = "Name of the EC2 key pair for SSH access to nodes"
  type        = string
  default     = ""
}

variable "source_security_group_ids" {
  description = "List of security group IDs allowed SSH access to nodes"
  type        = list(string)
  default     = []
}

variable "launch_template_name" {
  description = "Name of the launch template for EKS node groups"
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template for EKS node groups"
  type        = string
}

variable "fargate_pod_execution_role_arn" {
  description = "ARN of the IAM role for Fargate pod execution"
  type        = string
}

variable "oidc_thumbprint" {
  description = "Thumbprint of the OIDC provider for IAM roles for service accounts"
  type        = string
}