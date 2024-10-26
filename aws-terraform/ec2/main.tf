# EC2 Instance Configuration

# EC2:001: Disable public IP addresses for EC2 instances
# EC2:002: Enable encryption for EBS volumes
# EC2:003: Attach IAM roles to EC2 instances
# EC2:004: Enforce the use of IMDSv2 on EC2 instances
# EC2:006: Enable detailed monitoring for EC2 instances
# EC2:007: Use EBS-optimized instances
# EC2:010: Enable termination protection for critical EC2 instances
# EC2:011: Use latest generation instance types
# EC2:014: Implement EC2 instance isolation using dedicated hosts or instances
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  associate_public_ip_address = false
  ebs_optimized              = true
  monitoring                 = true
  disable_api_termination    = var.enable_termination_protection

  root_block_device {
    encrypted   = true
    kms_key_id  = var.kms_key_id
    volume_type = "gp3"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  instance_initiated_shutdown_behavior = "stop"

  tags = var.tags

  user_data = var.user_data

  tenancy = var.use_dedicated_instance ? "dedicated" : "default"
}

# EC2:002: Enable encryption for EBS volumes
# EC2:013: Enable EBS snapshot encryption
resource "aws_ebs_encryption_by_default" "main" {
  enabled = true
}

# EC2:008: Restrict security group ingress rules
resource "aws_security_group_rule" "ingress" {
  count             = length(var.ingress_rules)
  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  security_group_id = var.security_group_id
}

# EC2:015: Enable VPC flow logs
resource "aws_flow_log" "main" {
  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.flow_log_destination
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

# EC2:012: Implement EC2 instance patching using AWS Systems Manager
resource "aws_ssm_patch_baseline" "main" {
  name             = "ec2-patch-baseline"
  operating_system = "AMAZON_LINUX_2"

  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "PRODUCT"
      values = ["AmazonLinux2"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["SecurityUpdates"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}

resource "aws_ssm_patch_group" "main" {
  baseline_id = aws_ssm_patch_baseline.main.id
  patch_group = "ec2-instances"
}

resource "aws_ssm_maintenance_window" "main" {
  name     = "ec2-maintenance-window"
  schedule = "cron(0 2 ? * SUN *)"
  duration = "PT4H"
  allow_unassociated_targets = false
}

resource "aws_ssm_maintenance_window_target" "main" {
  window_id     = aws_ssm_maintenance_window.main.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup"
    values = ["ec2-instances"]
  }
}

resource "aws_ssm_maintenance_window_task" "main" {
  window_id        = aws_ssm_maintenance_window.main.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = var.ssm_service_role_arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.main.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}