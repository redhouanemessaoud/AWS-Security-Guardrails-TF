variable "security_configuration_name" {
  description = "Name of the EMR security configuration"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN of the KMS key for S3 encryption"
  type        = string
}

variable "local_disk_kms_key_arn" {
  description = "ARN of the KMS key for local disk encryption"
  type        = string
}

variable "enable_kerberos" {
  description = "Enable Kerberos authentication"
  type        = bool
  default     = false
}

variable "kdc_admin_password" {
  description = "Password for KDC admin"
  type        = string
  sensitive   = true
}

variable "kerberos_realm" {
  description = "Kerberos realm"
  type        = string
  default     = ""
}

variable "cross_realm_trust_realm" {
  description = "Cross-realm trust realm"
  type        = string
  default     = ""
}

variable "cross_realm_trust_domain" {
  description = "Cross-realm trust domain"
  type        = string
  default     = ""
}

variable "cross_realm_trust_admin_server" {
  description = "Cross-realm trust admin server"
  type        = string
  default     = ""
}

variable "cross_realm_trust_kdc_server" {
  description = "Cross-realm trust KDC server"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EMR cluster"
  type        = string
}

variable "emr_release_label" {
  description = "EMR release label"
  type        = string
  default     = "emr-6.6.0"
}

variable "applications" {
  description = "List of applications to install on the cluster"
  type        = list(string)
  default     = ["Hadoop", "Spark"]
}

variable "subnet_id" {
  description = "ID of the subnet to launch the cluster in"
  type        = string
}

variable "master_security_group_id" {
  description = "ID of the security group for the master node"
  type        = string
}

variable "slave_security_group_id" {
  description = "ID of the security group for the slave nodes"
  type        = string
}

variable "instance_profile" {
  description = "IAM instance profile for EC2 instances in the cluster"
  type        = string
}

variable "master_instance_type" {
  description = "Instance type for the master node"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_type" {
  description = "Instance type for core nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_count" {
  description = "Number of core nodes"
  type        = number
  default     = 2
}

variable "log_uri" {
  description = "S3 bucket for EMR cluster logs"
  type        = string
}

variable "service_role" {
  description = "IAM role for EMR service"
  type        = string
}

variable "enable_lake_formation" {
  description = "Enable Lake Formation integration"
  type        = bool
  default     = false
}