# AWS SNS Topic Module

# SNS:002 Enable server-side encryption for SNS topics using KMS CMK
# SNS:004 Enable SNS topic encryption in transit
resource "aws_sns_topic" "main" {
  name              = var.topic_name
  kms_master_key_id = var.kms_master_key_id
  tags              = var.tags

  # SNS:007 Enable SNS topic tagging
  tags = merge(
    var.tags,
    {
      Name = var.topic_name
    },
  )
}

# SNS:001 Use HTTPS endpoints for SNS subscriptions
# SNS:004 Enable SNS topic encryption in transit
resource "aws_sns_topic_subscription" "https_subscription" {
  count     = length(var.https_endpoints)
  topic_arn = aws_sns_topic.main.arn
  protocol  = "https"
  endpoint  = var.https_endpoints[count.index]
}

# SNS:003 Implement least privilege access for SNS topics
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.main.arn,
    ]

    sid = "__default_statement_ID"
  }
}

# SNS:006 Implement SNS message filtering
resource "aws_sns_topic_subscription" "filtered_subscription" {
  count     = length(var.filtered_subscriptions)
  topic_arn = aws_sns_topic.main.arn
  protocol  = var.filtered_subscriptions[count.index].protocol
  endpoint  = var.filtered_subscriptions[count.index].endpoint

  filter_policy = jsonencode(var.filtered_subscriptions[count.index].filter_policy)
}

# SNS:008 Implement SNS dead-letter queues
resource "aws_sns_topic_subscription" "dlq_subscription" {
  count                  = var.enable_dlq ? 1 : 0
  topic_arn              = aws_sns_topic.main.arn
  protocol               = "sqs"
  endpoint               = var.dlq_arn
  redrive_policy         = jsonencode({ deadLetterTargetArn = var.dlq_arn })
  raw_message_delivery   = true
}

# SNS:009 Implement SNS message attributes for enhanced security
resource "aws_sns_topic_subscription" "attribute_subscription" {
  count                  = length(var.attribute_subscriptions)
  topic_arn              = aws_sns_topic.main.arn
  protocol               = var.attribute_subscriptions[count.index].protocol
  endpoint               = var.attribute_subscriptions[count.index].endpoint
  raw_message_delivery   = true
  filter_policy_scope    = "MessageAttributes"
  filter_policy          = jsonencode(var.attribute_subscriptions[count.index].filter_policy)
}