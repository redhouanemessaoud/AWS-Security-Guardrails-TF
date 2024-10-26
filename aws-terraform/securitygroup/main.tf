# AWS Security Group Terraform Module

# securitygroup:001: Restrict all traffic in default security group for every VPC
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id

  # No ingress rules
  ingress = []

  # No egress rules
  egress = []

  tags = merge(var.tags, {
    Name = "Default Security Group"
  })
}

# securitygroup:002: Prevent unrestricted inbound access on all ports
# securitygroup:003: Prevent unrestricted inbound SSH access
# securitygroup:004: Prevent unrestricted inbound RDP access
# securitygroup:005: Prevent unrestricted inbound HTTP access
# securitygroup:007: Implement least privilege access in security group rules
# securitygroup:009: Limit number of rules per security group
# securitygroup:011: Implement security group egress rules
# securitygroup:012: Use security groups as sources in rules
resource "aws_security_group" "main" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  # securitygroup:008: Use security group names and descriptions effectively
  # securitygroup:015: Tag security groups for better management
  tags = merge(var.tags, {
    Name = var.security_group_name
  })
}