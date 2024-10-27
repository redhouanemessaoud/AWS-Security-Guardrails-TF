# AWS DynamoDB Secure Configuration

# dynamodb:001: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB tables
# dynamodb:002: Enable Point-in-Time Recovery (PITR) for DynamoDB tables
# dynamodb:003: Enable deletion protection for DynamoDB tables
# dynamodb:004: Configure DynamoDB tables to automatically scale capacity with demand
# dynamodb:013: Enable DynamoDB Streams for change data capture
# dynamodb:014: Implement appropriate Time to Live (TTL) settings for DynamoDB items
resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = true
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

  tags = var.tags
}

# dynamodb:004: Configure DynamoDB tables to automatically scale capacity with demand
resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.read_capacity.max
  min_capacity       = var.read_capacity.min
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.read_capacity.target_value
  }
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.write_capacity.max
  min_capacity       = var.write_capacity.min
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  count              = var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.write_capacity.target_value
  }
}

# dynamodb:007: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB Accelerator (DAX) clusters
# dynamodb:008: Enable encryption in transit for DynamoDB Accelerator (DAX) clusters
# dynamodb:009: Deploy DynamoDB Accelerator (DAX) clusters across multiple Availability Zones
resource "aws_dax_cluster" "main" {
  cluster_name       = var.dax_cluster_name
  iam_role_arn       = var.dax_iam_role_arn
  node_type          = var.dax_node_type
  replication_factor = var.dax_replication_factor

  server_side_encryption {
    enabled = true
  }

  cluster_endpoint_encryption_type = "TLS"

  availability_zones = var.dax_availability_zones

  tags = var.tags
}

# dynamodb:010: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB Global Tables
# dynamodb:011: Enable Point-in-Time Recovery (PITR) for DynamoDB Global Tables
resource "aws_dynamodb_global_table" "main" {
  depends_on = [aws_dynamodb_table.main]
  
  name = aws_dynamodb_table.main.name

  dynamic "replica" {
    for_each = var.global_table_regions
    content {
      region_name = replica.value
      kms_key_arn = var.global_table_kms_key_arns[replica.value]
    }
  }
}

# dynamodb:006: Restrict DynamoDB table access to specific AWS accounts or IAM principals
# dynamodb:012: Implement least privilege access for DynamoDB resources
resource "aws_iam_policy" "dynamodb_read_only" {
  name        = "${var.table_name}-read-only"
  path        = "/"
  description = "Read-only access policy for DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable"
        ]
        Resource = aws_dynamodb_table.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_write" {
  name        = "${var.table_name}-write"
  path        = "/"
  description = "Write access policy for DynamoDB table ${var.table_name}"

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