variable "execution_role_arn" {
  description = "The ARN of the IAM role used to run the EBS snapshot policy"
  type        = string
}

variable "retention_count" {
  description = "The number of snapshots to retain"
  type        = number
  default     = 7
}

variable "target_tags" {
  description = "Tags to use for identifying volumes to snapshot"
  type        = map(string)
  default     = {}
}

variable "cross_region_copy_rules" {
  description = "List of cross-region copy rules"
  type = list(object({
    target_region   = string
    cmk_arn         = string
    retain_interval = number
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the DLM lifecycle policy"
  type        = map(string)
  default     = {}
}

variable "enable_cross_account_sharing" {
  description = "Enable cross-account snapshot sharing"
  type        = bool
  default     = false
}

variable "cross_account_target_region" {
  description = "Target region for cross-account snapshot sharing"
  type        = string
  default     = ""
}

variable "cross_account_cmk_arn" {
  description = "CMK ARN for encrypting cross-account shared snapshots"
  type        = string
  default     = ""
}

variable "cross_account_target_accounts" {
  description = "List of AWS account IDs to share snapshots with"
  type        = list(string)
  default     = []
}

variable "cross_account_target_tags" {
  description = "Tags to use for identifying volumes for cross-account sharing"
  type        = map(string)
  default     = {}
}

variable "enable_fast_snapshot_restore" {
  description = "Enable Fast Snapshot Restore for critical volumes"
  type        = bool
  default     = false
}

variable "fast_restore_availability_zones" {
  description = "List of Availability Zones to enable Fast Snapshot Restore"
  type        = list(string)
  default     = []
}

variable "fast_restore_count" {
  description = "Number of snapshots to be enabled for Fast Snapshot Restore"
  type        = number
  default     = 1
}

variable "fast_restore_target_tags" {
  description = "Tags to use for identifying volumes for Fast Snapshot Restore"
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for DLM policy execution alerts"
  type        = string
}