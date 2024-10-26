# AWS Organizations Secure Configuration

# organizations:001 - Enable AWS Organizations AI services opt-out policy
resource "aws_organizations_policy" "ai_opt_out" {
  name    = "ai-services-opt-out-policy"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OptOutOfAIServices"
        Effect = "Deny"
        Action = [
          "comprehend:DetectSyntax",
          "rekognition:DetectFaces",
          "translate:TranslateText"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "ai_opt_out" {
  policy_id = aws_organizations_policy.ai_opt_out.id
  target_id = var.organization_id
}

# organizations:002 - Restrict AWS Regions using Service Control Policies (SCPs)
resource "aws_organizations_policy" "region_restriction" {
  name    = "region-restriction-policy"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictRegions"
        Effect = "Deny"
        NotAction = [
          "cloudfront:*",
          "iam:*",
          "route53:*",
          "support:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "region_restriction" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = var.organization_id
}

# organizations:003 - Enable and attach tag policies in AWS Organizations
resource "aws_organizations_policy" "tag_policy" {
  name    = "organization-tag-policy"
  content = jsonencode({
    tags = {
      environment = {
        tag_key = {
          @@assign = "Environment"
        }
        tag_value = {
          @@assign = ["Production", "Development", "Test"]
        }
        enforced_for = {
          @@assign = ["ec2:instance", "rds:db"]
        }
      }
    }
  })
  type = "TAG_POLICY"
}

resource "aws_organizations_policy_attachment" "tag_policy" {
  policy_id = aws_organizations_policy.tag_policy.id
  target_id = var.organization_id
}

# organizations:004 - Restrict AWS Organizations delegated administrators to trusted accounts
# This is managed through AWS Organizations console or API, not directly in Terraform

# organizations:005 - Implement AWS Organizations for centralized management
# This is typically done through AWS Organizations console or API, not directly in Terraform

# organizations:006 - Enable AWS Organizations Service Control Policies (SCPs)
resource "aws_organizations_policy" "scp_example" {
  name    = "example-scp"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "ec2:RunInstances"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "ec2:InstanceType" = ["t2.micro", "t3.micro"]
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_example" {
  policy_id = aws_organizations_policy.scp_example.id
  target_id = var.organization_id
}

# organizations:007 - Implement a multi-account strategy using AWS Organizations
# This is typically done through AWS Organizations console or API, not directly in Terraform

# organizations:008 - Enable AWS Config aggregation using AWS Organizations
resource "aws_config_configuration_aggregator" "organization" {
  name = "organization-config-aggregator"
  organization_aggregation_source {
    role_arn = var.config_aggregator_role_arn
  }
}

# organizations:009 - Implement AWS Organizations Backup Policies
resource "aws_organizations_policy" "backup_policy" {
  name    = "organization-backup-policy"
  content = jsonencode({
    plans = {
      daily_backup = {
        regions = { @@assign = var.allowed_regions }
        rules = {
          daily_rule = {
            schedule_expression = { @@assign = "cron(0 5 ? * * *)" }
            start_window_minutes = { @@assign = 60 }
            target_backup_vault_name = { @@assign = "Default" }
            lifecycle = {
              delete_after_days = { @@assign = 30 }
            }
          }
        }
        selections = {
          tags = {
            backup = {
              iam_role_arn = { @@assign = var.backup_role_arn }
              tag_key = { @@assign = "Backup" }
              tag_value = { @@assign = ["Yes"] }
            }
          }
        }
      }
    }
  })
  type = "BACKUP_POLICY"
}

resource "aws_organizations_policy_attachment" "backup_policy" {
  policy_id = aws_organizations_policy.backup_policy.id
  target_id = var.organization_id
}

# organizations:010 - Enable AWS Security Hub integration with AWS Organizations
# This is typically done through AWS Security Hub console or API, not directly in Terraform

# organizations:011 - Implement AWS Organizations IAM Access Analyzer Policies
resource "aws_organizations_policy" "access_analyzer_policy" {
  name    = "organization-access-analyzer-policy"
  content = jsonencode({
    services = {
      "@@operators_allowed_for_child_policies" = ["@@none"]
      "access-analyzer" = {
        "@@operators_allowed_for_child_policies" = ["@@none"]
        "features" = {
          "@@operators_allowed_for_child_policies" = ["@@none"]
          "enableAccessAnalyzer" = {
            "@@assign" = "true"
          }
        }
      }
    }
  })
  type = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "access_analyzer_policy" {
  policy_id = aws_organizations_policy.access_analyzer_policy.id
  target_id = var.organization_id
}

# organizations:012 - Use AWS Organizations to centralize CloudTrail logging
# This is typically done through AWS CloudTrail console or API, not directly in Terraform

# organizations:013 - Implement AWS Organizations password policy
resource "aws_organizations_policy" "password_policy" {
  name    = "organization-password-policy"
  content = jsonencode({
    PasswordPolicy = {
      MinimumPasswordLength = 14
      RequireSymbols = true
      RequireNumbers = true
      RequireUppercaseCharacters = true
      RequireLowercaseCharacters = true
      AllowUsersToChangePassword = true
      ExpirePasswords = true
      MaxPasswordAge = 90
      PasswordReusePrevention = 24
      HardExpiry = false
    }
  })
  type = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "password_policy" {
  policy_id = aws_organizations_policy.password_policy.id
  target_id = var.organization_id
}

# organizations:014 - Enable AWS Organizations consolidated billing
# This is typically enabled by default when creating an organization, not directly manageable in Terraform

# organizations:015 - Implement AWS Organizations data residency policies
resource "aws_organizations_policy" "data_residency" {
  name    = "data-residency-policy"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceDataResidency"
        Effect = "Deny"
        Action = [
          "s3:CreateBucket",
          "rds:CreateDBInstance",
          "dynamodb:CreateTable"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "data_residency" {
  policy_id = aws_organizations_policy.data_residency.id
  target_id = var.organization_id
}