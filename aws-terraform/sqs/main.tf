# AWS SQS Queue Security Configuration

# SQS:001: Enable Server-Side Encryption with AWS KMS for SQS Queues
# SQS:002: Restrict SQS Queue Access to Specific AWS Accounts or Services
# SQS:003: Implement Least Privilege Access for SQS Queues
# SQS:004: Enable Dead-Letter Queues for SQS
# SQS:007: Implement Message Retention Period for SQS Queues
# SQS:008: Enable Server-Side Encryption in Transit for SQS
# SQS:009: Implement SQS Queue Tagging
resource "aws_sqs_queue" "secure_queue" {
  name                        = var.queue_name
  kms_master_key_id           = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300
  visibility_timeout_seconds  = var.visibility_timeout
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.is_fifo_queue
  content_based_deduplication = var.content_based_deduplication

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_aws_accounts
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.secure_queue.arn
      }
    ]
  })
}

# SQS:004: Enable Dead-Letter Queues for SQS
resource "aws_sqs_queue" "dead_letter_queue" {
  name                        = "${var.queue_name}-dlq"
  kms_master_key_id           = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300
  message_retention_seconds   = var.dlq_message_retention_seconds

  tags = merge(var.tags, {
    Name = "${var.queue_name}-dlq"
  })
}

# SQS:010: Configure SQS Queue Alarms
resource "aws_cloudwatch_metric_alarm" "queue_depth_alarm" {
  alarm_name          = "${var.queue_name}-depth-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.queue_depth_threshold
  alarm_description   = "This metric monitors queue depth"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    QueueName = aws_sqs_queue.secure_queue.name
  }
}

resource "aws_cloudwatch_metric_alarm" "oldest_message_alarm" {
  alarm_name          = "${var.queue_name}-oldest-message-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.oldest_message_threshold
  alarm_description   = "This metric monitors the age of the oldest message in the queue"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    QueueName = aws_sqs_queue.secure_queue.name
  }
}

# SQS:003: Implement Least Privilege Access for SQS Queues
resource "aws_iam_policy" "sqs_read_policy" {
  name        = "${var.queue_name}-read-policy"
  description = "Policy for read access to SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.secure_queue.arn
      }
    ]
  })
}

resource "aws_iam_policy" "sqs_write_policy" {
  name        = "${var.queue_name}-write-policy"
  description = "Policy for write access to SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.secure_queue.arn
      }
    ]
  })
}