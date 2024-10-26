# Amazon MQ Broker Configuration

# mq:001: Enable automatic minor version upgrades for Amazon MQ brokers
# mq:002: Enable audit logging for Amazon MQ brokers
# mq:003: Use AWS KMS Customer Managed Key (CMK) for Amazon MQ broker encryption
# mq:004: Disable public accessibility for Amazon MQ brokers
# mq:005: Enable general logging for Amazon MQ brokers
# mq:006: Keep Amazon MQ brokers updated to the latest major version
# mq:009: Enable encryption in transit for Amazon MQ brokers
# mq:010: Configure Amazon MQ brokers in a multi-AZ deployment
# mq:013: Implement message persistence for Amazon MQ brokers
# mq:014: Use strong authentication mechanisms for Amazon MQ broker access
resource "aws_mq_broker" "main" {
  broker_name = var.broker_name
  engine_type = var.engine_type
  engine_version = var.engine_version
  host_instance_type = var.instance_type
  security_groups = var.security_group_ids
  subnet_ids = var.subnet_ids

  auto_minor_version_upgrade = true
  publicly_accessible = false
  deployment_mode = "ACTIVE_STANDBY_MULTI_AZ"

  encryption_options {
    use_aws_owned_key = false
    kms_key_id = var.kms_key_id
  }

  logs {
    general = true
    audit = true
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone = var.maintenance_time_zone
  }

  user {
    username = var.admin_username
    password = var.admin_password
  }

  configuration {
    id = aws_mq_configuration.main.id
    revision = aws_mq_configuration.main.latest_revision
  }
}

# mq:009: Enable encryption in transit for Amazon MQ brokers
resource "aws_mq_configuration" "main" {
  name = "${var.broker_name}-config"
  engine_type = var.engine_type
  engine_version = var.engine_version

  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyPlugin/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin/>
  </plugins>
  <sslContext>
    <sslContext keyStore="file:${var.keystore_path}"
                keyStorePassword="${var.keystore_password}"
                trustStore="file:${var.truststore_path}"
                trustStorePassword="${var.truststore_password}"/>
  </sslContext>
</broker>
DATA
}

# mq:008: Implement least privilege access for Amazon MQ brokers
resource "aws_iam_policy" "mq_read_access" {
  name        = "mq-read-access"
  path        = "/"
  description = "IAM policy for read access to Amazon MQ"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "mq:DescribeBroker",
          "mq:DescribeConfiguration",
          "mq:DescribeUser",
          "mq:ListBrokers",
          "mq:ListConfigurations",
          "mq:ListUsers"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "mq_write_access" {
  name        = "mq-write-access"
  path        = "/"
  description = "IAM policy for write access to Amazon MQ"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "mq:CreateBroker",
          "mq:DeleteBroker",
          "mq:RebootBroker",
          "mq:UpdateBroker",
          "mq:CreateConfiguration",
          "mq:DeleteConfiguration",
          "mq:UpdateConfiguration",
          "mq:CreateUser",
          "mq:DeleteUser",
          "mq:UpdateUser"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# mq:012: Enable CloudWatch monitoring for Amazon MQ brokers
resource "aws_cloudwatch_metric_alarm" "mq_cpu_utilization" {
  alarm_name          = "${var.broker_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CpuUtilization"
  namespace           = "AWS/AmazonMQ"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors MQ broker CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    Broker = aws_mq_broker.main.id
  }
}