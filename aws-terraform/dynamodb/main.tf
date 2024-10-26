# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  # dynamodb:001: Enable encryption at rest for DynamoDB tables using AWS KMS Customer Managed Keys (CMK)
  # dynamodb:002: Enable Point-in-Time Recovery (PITR) for DynamoDB tables
  # dynamodb:003: Enable deletion protection for DynamoDB tables
  # dynamodb:009: Enable auto-scaling for DynamoDB tables
  # dynamodb:013: Enable DynamoDB Streams for critical tables
  # dynamodb:014: Implement DynamoDB table tagging strategy
  # dynamodb:015: Configure DynamoDB Time to Live (TTL) for applicable tables
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true

  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? var.stream_view_type : null

  ttl {
    enabled        = var.enable_ttl
    attribute_name = var.ttl_attribute_name
  }

  tags = var.tags

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }
}

# dynamodb:009: Enable auto-scaling for DynamoDB tables
resource "aws_appautoscaling_target" "read_target" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.read_max_capacity
  min_capacity       = var.read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.read_target_utilization
  }
}

resource "aws_appautoscaling_target" "write_target" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.write_max_capacity
  min_capacity       = var.write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write_policy" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.write_target_utilization
  }
}

# dynamodb:004: Enable encryption at rest for DynamoDB Accelerator (DAX) clusters using AWS KMS Customer Managed Keys (CMK)
# dynamodb:005: Enable encryption in transit for DynamoDB Accelerator (DAX) clusters
# dynamodb:006: Deploy DynamoDB Accelerator (DAX) clusters across multiple Availability Zones
resource "aws_dax_cluster" "main" {
  count              = var.create_dax_cluster ? 1 : 0
  cluster_name       = var.dax_cluster_name
  iam_role_arn       = var.dax_iam_role_arn
  node_type          = var.dax_node_type
  replication_factor = var.dax_replication_factor
  server_side_encryption {
    enabled = true
  }
  cluster_endpoint_encryption_type = "TLS"
  availability_zones               = var.dax_availability_zones
  tags                             = var.tags
}

# dynamodb:008: Restrict DynamoDB table access to specific AWS accounts or IAM principals
# dynamodb:012: Implement fine-grained access control for DynamoDB tables
resource "aws_iam_policy" "dynamodb_read_policy" {
  name        = "${var.table_name}-read-policy"
  path        = "/"
  description = "IAM policy for reading from a specific DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_write_policy" {
  name        = "${var.table_name}-write-policy"
  path        = "/"
  description = "IAM policy for writing to a specific DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.main.arn
      }
    ]
  })
}

# dynamodb:010: Enable encryption at rest for DynamoDB global table replicas using AWS KMS Customer Managed Keys (CMK)
resource "aws_dynamodb_global_table" "main" {
  count = var.create_global_table ? 1 : 0
  depends_on = [
    aws_dynamodb_table.main
  ]

  name = var.table_name

  dynamic "replica" {
    for_each = var.global_table_regions
    content {
      region_name = replica.value
      kms_key_arn = var.global_table_kms_key_arns[replica.value]
    }
  }
}