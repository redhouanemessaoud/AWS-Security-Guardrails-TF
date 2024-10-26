variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
  type        = bool
  default     = false
}

variable "flow_log_role_arn" {
  description = "ARN of the IAM role for VPC flow logs"
  type        = string
}

variable "flow_log_destination" {
  description = "ARN of the destination for VPC flow logs (e.g., CloudWatch log group or S3 bucket)"
  type        = string
}

variable "firewall_policy_arn" {
  description = "ARN of the Network Firewall policy"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "nlb_arns" {
  description = "List of Network Load Balancer ARNs for VPC endpoint service"
  type        = list(string)
}

variable "allowed_principal_arn" {
  description = "ARN of the principal allowed to connect to the VPC endpoint service"
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the VPC to peer with"
  type        = string
}

variable "auto_accept_peering" {
  description = "Auto-accept the peering connection"
  type        = bool
  default     = false
}

variable "peering_route_table_ids" {
  description = "List of route table IDs to add peering routes to"
  type        = list(string)
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer VPC"
  type        = string
}

variable "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  type        = string
}

variable "customer_gateway_id" {
  description = "ID of the customer gateway"
  type        = string
}

variable "tunnel1_inside_cidr" {
  description = "Inside CIDR for the first VPN tunnel"
  type        = string
}

variable "tunnel2_inside_cidr" {
  description = "Inside CIDR for the second VPN tunnel"
  type        = string
}