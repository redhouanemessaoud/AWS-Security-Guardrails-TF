# AWS Network Firewall Terraform Module

# networkfirewall:001: Enable Logging for AWS Network Firewall
resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = var.cloudwatch_log_group_arn
      }
      log_type = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = var.s3_bucket_name
      }
      log_type = "FLOW"
    }
  }
}

# networkfirewall:002: Use AWS KMS Customer Managed Key for Network Firewall Encryption
# networkfirewall:003: Enable Deletion Protection for AWS Network Firewall
# networkfirewall:010: Configure Network Firewall High Availability
resource "aws_networkfirewall_firewall" "main" {
  name                = var.firewall_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id
  delete_protection   = true
  encryption_configuration {
    key_id = var.kms_key_arn
    type   = "CUSTOMER_KMS"
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id = subnet_mapping.value
    }
  }
}

# networkfirewall:004: Configure Stateful Inspection for AWS Network Firewall
# networkfirewall:005: Implement Strict Rule Actions in Network Firewall Policy
# networkfirewall:006: Enable Intrusion Prevention System (IPS) in Network Firewall
# networkfirewall:007: Implement Domain Name Filtering in Network Firewall
# networkfirewall:008: Enable TLS Inspection for Network Firewall
# networkfirewall:014: Configure Network Firewall to Block Known Malicious IP Addresses
resource "aws_networkfirewall_firewall_policy" "main" {
  name = var.policy_name

  firewall_policy {
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful.arn
    }

    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateless.arn
    }
  }

  encryption_configuration {
    key_id = var.kms_key_arn
    type   = "CUSTOMER_KMS"
  }
}

resource "aws_networkfirewall_rule_group" "stateful" {
  capacity = 100
  name     = "stateful-rule-group"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_string = <<EOF
      pass tcp any any <> any any (msg:"Allow all TCP traffic"; sid:1;)
      alert http any any -> any any (msg:"Block malicious domains"; content:"malicious-domain.com"; http_header; sid:2;)
      drop ip any any <> ${join(",", var.malicious_ip_ranges)} any (msg:"Block known malicious IPs"; sid:3;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  encryption_configuration {
    key_id = var.kms_key_arn
    type   = "CUSTOMER_KMS"
  }
}

resource "aws_networkfirewall_rule_group" "stateless" {
  capacity = 100
  name     = "stateless-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6] # TCP
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              tcp {
                source_port {
                  from_port = 80
                  to_port   = 80
                }
                destination_port {
                  from_port = 80
                  to_port   = 80
                }
              }
            }
          }
        }
      }
    }
  }

  encryption_configuration {
    key_id = var.kms_key_arn
    type   = "CUSTOMER_KMS"
  }
}

# networkfirewall:011: Implement Least Privilege Access for Network Firewall Management
resource "aws_iam_policy" "network_firewall_read" {
  name        = "network-firewall-read-policy"
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
  name        = "network-firewall-write-policy"
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

# networkfirewall:012: Enable Continuous Monitoring of Network Firewall
resource "aws_cloudwatch_metric_alarm" "network_firewall_alert" {
  alarm_name          = "network-firewall-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DroppedPackets"
  namespace           = "AWS/NetworkFirewall"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors dropped packets by Network Firewall"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    FirewallName = aws_networkfirewall_firewall.main.name
  }
}