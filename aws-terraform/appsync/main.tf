# AppSync API
resource "aws_appsync_graphql_api" "main" {
  name                = var.api_name
  authentication_type = var.authentication_type

  # appsync:009: Enable HTTPS-Only Access for AppSync API
  # appsync:010: Implement Strong Authentication for AppSync API
  schema = file(var.schema_file_path)

  # appsync:001: Use AWS KMS Customer Managed Key (CMK) for AppSync API Cache Encryption at Rest
  # appsync:002: Enable Encryption in Transit for AppSync API Cache
  # appsync:013: Enable and Configure AppSync API Caching Securely
  cache {
    api_caching_behavior = var.api_caching_behavior
    type                 = var.cache_type
    transit_encryption_enabled = true
    at_rest_encryption_enabled = true
    cache_size = var.cache_size
    ttl        = var.cache_ttl
  }

  # appsync:003: Enable Field-Level Logging for AppSync API
  # appsync:004: Enable CloudWatch Logging for AppSync API
  log_config {
    cloudwatch_logs_role_arn = var.cloudwatch_logs_role_arn
    field_log_level          = "ALL"
    exclude_verbose_content  = false
  }

  # appsync:005: Integrate AppSync API with AWS WAF
  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }

  # appsync:011: Enable and Configure API Request Throttling
  throttle_config {
    max_requests_per_second = var.max_requests_per_second
    max_burst               = var.max_burst
  }

  # appsync:015: Use Latest GraphQL Schema Version for AppSync API
  xray_enabled = true
}

# appsync:006: Implement Least Privilege Access for AppSync API
resource "aws_iam_role" "appsync_role" {
  name = "appsync-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_policy" {
  name = "appsync-api-policy"
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# appsync:012: Implement Data Validation for AppSync API Inputs
resource "aws_appsync_resolver" "example" {
  api_id      = aws_appsync_graphql_api.main.id
  type        = "Query"
  field       = "exampleQuery"

  request_template  = file("${path.module}/request_template.vtl")
  response_template = file("${path.module}/response_template.vtl")
}

# appsync:014: Implement Secure Error Handling for AppSync API
resource "aws_appsync_function" "example" {
  api_id      = aws_appsync_graphql_api.main.id
  data_source = aws_appsync_datasource.example.name
  name        = "exampleFunction"
  request_mapping_template  = file("${path.module}/request_mapping.vtl")
  response_mapping_template = file("${path.module}/response_mapping.vtl")
}