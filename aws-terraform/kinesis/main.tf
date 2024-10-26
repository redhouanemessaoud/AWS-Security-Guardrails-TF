# Kinesis Stream
resource "aws_kinesis_stream" "main" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.retention_period

  # kinesis:001: Use AWS KMS Customer Managed Key (CMK) for Kinesis Stream Encryption
  encryption_type = "KMS"
  kms_key_id      = var.kms_key_id

  # kinesis:007: Enable Enhanced Monitoring for Kinesis Data Streams
  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  # kinesis:008: Implement Secure Data Retention for Kinesis Streams
  retention_period = var.retention_period

  tags = var.tags
}

# kinesis:002: Enable Enhanced Fan-Out for Kinesis Data Streams Consumers
resource "aws_kinesis_stream_consumer" "enhanced_fanout" {
  count        = var.enable_enhanced_fanout ? 1 : 0
  name         = "${var.stream_name}-consumer"
  stream_arn   = aws_kinesis_stream.main.arn
  consumer_arn = "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${var.stream_name}/consumer/${var.stream_name}-consumer"
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "main" {
  count       = var.create_firehose_delivery_stream ? 1 : 0
  name        = "${var.stream_name}-firehose"
  destination = "s3"

  # kinesis:004: Enable Server-Side Encryption for Kinesis Firehose Delivery Streams
  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = var.kms_key_id
  }

  s3_configuration {
    role_arn   = var.firehose_role_arn
    bucket_arn = var.firehose_s3_bucket_arn
  }

  tags = var.tags
}

# kinesis:006: Implement Monitoring and Alerting for Kinesis Streams
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.stream_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GetRecords.Success"
  namespace           = "AWS/Kinesis"
  period              = "300"
  statistic           = "Average"
  threshold           = var.error_rate_threshold
  alarm_description   = "This metric monitors Kinesis stream error rate"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    StreamName = aws_kinesis_stream.main.name
  }
}

# kinesis:003: Implement Least Privilege Access for Kinesis Streams
resource "aws_iam_policy" "kinesis_read_policy" {
  name        = "${var.stream_name}-read-policy"
  path        = "/"
  description = "IAM policy for reading from a Kinesis stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ]
        Effect   = "Allow"
        Resource = aws_kinesis_stream.main.arn
      },
    ]
  })
}

resource "aws_iam_policy" "kinesis_write_policy" {
  name        = "${var.stream_name}-write-policy"
  path        = "/"
  description = "IAM policy for writing to a Kinesis stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Effect   = "Allow"
        Resource = aws_kinesis_stream.main.arn
      },
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}