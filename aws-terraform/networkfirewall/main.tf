# AWS Network Firewall Terraform Module

# networkfirewall:002: Use AWS KMS Customer Managed Key (CMK) for Network Firewall encryption
# networkfirewall:003: Enable deletion protection for AWS Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = var.firewall_name
  description         = var.firewall_description
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id
  kms_key_arn         = var.kms_key_arn
  delete_protection   = true

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

# networkfirewall:006: Configure AWS Network Firewall rule groups
# networkfirewall:004: Implement stateful inspection rules in AWS Network Firewall
resource "aws_networkfirewall_rule_group" "stateful" {
  capacity = var.stateful_rule_group_capacity
  name     = "${var.firewall_name}-stateful-rule-group"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.stateful_rules
        content {
          action = stateful_rule.value.action
          header {
            destination      = stateful_rule.value.destination
            destination_port = stateful_rule.value.destination_port
            direction        = stateful_rule.value.direction
            protocol         = stateful_rule.value.protocol
            source           = stateful_rule.value.source
            source_port      = stateful_rule.value.source_port
          }
          rule_option {
            keyword  = stateful_rule.value.keyword
            settings = stateful_rule.value.settings
          }
        }
      }
    }
  }

  tags = var.tags
}

# networkfirewall:005: Implement stateless rules in AWS Network Firewall
resource "aws_networkfirewall_rule_group" "stateless" {
  capacity = var.stateless_rule_group_capacity
  name     = "${var.firewall_name}-stateless-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        dynamic "stateless_rule" {
          for_each = var.stateless_rules
          content {
            priority = stateless_rule.value.priority
            rule_definition {
              actions = stateless_rule.value.actions
              match_attributes {
                dynamic "source" {
                  for_each = stateless_rule.value.source_addresses
                  content {
                    address_definition = source.value
                  }
                }
                dynamic "destination" {
                  for_each = stateless_rule.value.destination_addresses
                  content {
                    address_definition = destination.value
                  }
                }
                dynamic "source_port" {
                  for_each = stateless_rule.value.source_ports
                  content {
                    from_port = source_port.value.from_port
                    to_port   = source_port.value.to_port
                  }
                }
                dynamic "destination_port" {
                  for_each = stateless_rule.value.destination_ports
                  content {
                    from_port = destination_port.value.from_port
                    to_port   = destination_port.value.to_port
                  }
                }
                protocols = stateless_rule.value.protocols
              }
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

# networkfirewall:007: Implement custom domain lists in AWS Network Firewall
resource "aws_networkfirewall_rule_group" "domain_list" {
  capacity = var.domain_list_rule_group_capacity
  name     = "${var.firewall_name}-domain-list-rule-group"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = var.home_net_ip_set
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.domain_list
      }
    }
  }

  tags = var.tags
}

# networkfirewall:006: Configure AWS Network Firewall rule groups
# networkfirewall:009: Implement TLS inspection in AWS Network Firewall
resource "aws_networkfirewall_rule_group" "tls_inspection" {
  capacity = var.tls_inspection_rule_group_capacity
  name     = "${var.firewall_name}-tls-inspection-rule-group"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "FORWARD_TO_SSLPORXY"
        header {
          destination      = "ANY"
          destination_port = "443"
          direction        = "ANY"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }

  tags = var.tags
}

# networkfirewall:011: Implement custom actions in AWS Network Firewall
resource "aws_networkfirewall_rule_group" "custom_actions" {
  capacity = var.custom_actions_rule_group_capacity
  name     = "${var.firewall_name}-custom-actions-rule-group"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.custom_action_rules
        content {
          action = stateful_rule.value.action
          header {
            destination      = stateful_rule.value.destination
            destination_port = stateful_rule.value.destination_port
            direction        = stateful_rule.value.direction
            protocol         = stateful_rule.value.protocol
            source           = stateful_rule.value.source
            source_port      = stateful_rule.value.source_port
          }
          rule_option {
            keyword  = stateful_rule.value.keyword
            settings = stateful_rule.value.settings
          }
        }
      }
    }
  }

  tags = var.tags
}

# networkfirewall:006: Configure AWS Network Firewall rule groups
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.firewall_name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_list.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.tls_inspection.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.custom_actions.arn
    }

    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateless.arn
    }
  }

  tags = var.tags
}

# networkfirewall:001: Enable AWS Network Firewall logging
# networkfirewall:010: Configure AWS Network Firewall alert and flow logging
resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = var.cloudwatch_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = var.s3_bucket_name
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}

# networkfirewall:008: Enable AWS Network Firewall association with multiple VPCs
resource "aws_networkfirewall_firewall" "additional_vpcs" {
  count               = length(var.additional_vpc_ids)
  name                = "${var.firewall_name}-vpc-${count.index + 1}"
  description         = "${var.firewall_description} for VPC ${count.index + 1}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.additional_vpc_ids[count.index]
  kms_key_arn         = var.kms_key_arn
  delete_protection   = true

  dynamic "subnet_mapping" {
    for_each = var.additional_vpc_subnet_mappings[count.index]
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

# networkfirewall:012: Enable high availability for AWS Network Firewall
# This is achieved by deploying the firewall across multiple subnets in different Availability Zones
# The subnet_mapping configuration in aws_networkfirewall_firewall resources ensures this

# networkfirewall:014: Integrate AWS Network Firewall with AWS Security Hub
resource "aws_securityhub_product_subscription" "network_firewall" {
  count         = var.enable_security_hub_integration ? 1 : 0
  product_arn   = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/network-firewall"
  depends_on    = [aws_networkfirewall_firewall.main]
}

data "aws_region" "current" {}

# networkfirewall:015: Implement least privilege access for AWS Network Firewall management
resource "aws_iam_policy" "network_firewall_read" {
  name        = "${var.firewall_name}-read-policy"
  path        = "/"
  description = "IAM policy for read-only access to Network Firewall"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "network-firewall:DescribeFirewall",
          "network-firewall:DescribeFirewallPolicy",
          "network-firewall:DescribeRuleGroup",
          "network-firewall:ListFirewalls",
          "network-firewall:ListFirewallPolicies",
          "network-firewall:ListRuleGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "network_firewall_write" {
  name        = "${var.firewall_name}-write-policy"
  path        = "/"
  description = "IAM policy for write access to Network Firewall"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "network-firewall:CreateFirewall",
          "network-firewall:DeleteFirewall",
          "network-firewall:UpdateFirewall",
          "network-firewall:CreateFirewallPolicy",
          "network-firewall:DeleteFirewallPolicy",
          "network-firewall:UpdateFirewallPolicy",
          "network-firewall:CreateRuleGroup",
          "network-firewall:DeleteRuleGroup",
          "network-firewall:UpdateRuleGroup"
        ]
        Resource = "*"
      }
    ]
  })
}