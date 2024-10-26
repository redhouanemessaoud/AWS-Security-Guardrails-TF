# AWS Auto Scaling Group Terraform Module

# autoscaling:005: Use EC2 launch templates for Auto Scaling groups
resource "aws_launch_template" "main" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type

  # autoscaling:002: Enable Instance Metadata Service Version 2 (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # autoscaling:003: Disable public IP address assignment
  network_interfaces {
    associate_public_ip_address = false
  }

  # autoscaling:010: Use AWS Systems Manager for instance management
  iam_instance_profile {
    name = var.ssm_instance_profile_name
  }

  # autoscaling:009: Enable detailed monitoring
  monitoring {
    enabled = true
  }

  # autoscaling:006: Apply consistent tagging strategy
  tags = var.tags
}

# autoscaling:001: Use multiple instance types across multiple Availability Zones
resource "aws_autoscaling_group" "main" {
  name                = "${var.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  # autoscaling:005: Use EC2 launch templates
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version            = "$Latest"
      }

      override {
        instance_type = var.instance_type
      }
    }

    instances_distribution {
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }

  # autoscaling:004: Use ELB health checks
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # autoscaling:006: Apply consistent tagging strategy
  tags = concat(
    [for key, value in var.tags : {
      key                 = key
      value               = value
      propagate_at_launch = true
    }],
    [
      {
        key                 = "Name"
        value               = "${var.name_prefix}-instance"
        propagate_at_launch = true
      }
    ]
  )

  # autoscaling:008: Implement instance refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # autoscaling:013: Implement appropriate termination policies
  termination_policies = ["OldestLaunchTemplate", "OldestInstance"]

  # autoscaling:011: Implement lifecycle hooks
  initial_lifecycle_hook {
    name                 = "${var.name_prefix}-launch-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  initial_lifecycle_hook {
    name                 = "${var.name_prefix}-terminate-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  }
}

# autoscaling:015: Implement appropriate scaling policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# autoscaling:009: Enable detailed monitoring (CloudWatch alarms)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Scale out if CPU > 75% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.name_prefix}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in if CPU < 30% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}