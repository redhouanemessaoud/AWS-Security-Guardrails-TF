# AWS API Gateway v1 Secure Configuration

# apigatewayv1:001: Use private API Gateway endpoints
resource "aws_api_gateway_rest_api" "main" {
  name                         = var.api_name
  description                  = var.api_description
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }
}

# apigatewayv1:002: Enable AWS X-Ray tracing for API Gateway REST API stages
# apigatewayv1:003: Attach AWS WAF ACL to API Gateway stages
# apigatewayv1:004: Enable logging for API Gateway stages
# apigatewayv1:005: Enable client certificate authentication for backend endpoints
# apigatewayv1:006: Encrypt API Gateway REST API cache data at rest
# apigatewayv1:008: Use latest TLS security policy for API Gateway custom domain names
# apigatewayv1:011: Enable API Gateway caching with encryption
# apigatewayv1:012: Disable detailed execution logging in API Gateway method settings
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  xray_tracing_enabled = true
  
  access_log_settings {
    destination_arn = var.cloudwatch_log_group_arn
    format          = var.log_format
  }

  cache_cluster_enabled = var.enable_cache
  cache_cluster_size    = var.cache_cluster_size
  
  client_certificate_id = aws_api_gateway_client_certificate.main.id

  variables = {
    "loggingLevel" = "INFO"
  }

  web_acl_arn = var.waf_acl_arn

  tags = var.tags
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    logging_level        = "INFO"
    data_trace_enabled   = false
    metrics_enabled      = true
    caching_enabled      = var.enable_cache
    cache_data_encrypted = true
    cache_ttl_in_seconds = var.cache_ttl
  }
}

resource "aws_api_gateway_client_certificate" "main" {
  description = "Client certificate for backend authentication"
}

# apigatewayv1:007: Configure authorizers for API Gateway at API or method level
resource "aws_api_gateway_authorizer" "main" {
  name                   = "custom-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  authorizer_uri         = var.authorizer_lambda_arn
  authorizer_credentials = var.authorizer_role_arn
}

# apigatewayv1:009: Enable request validation for API Gateway methods
resource "aws_api_gateway_request_validator" "main" {
  name                  = "request-validator"
  rest_api_id           = aws_api_gateway_rest_api.main.id
  validate_request_body = true
  validate_request_parameters = true
}

# apigatewayv1:010: Implement throttling for API Gateway methods
resource "aws_api_gateway_usage_plan" "main" {
  name = "usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = var.quota_limit
    offset = var.quota_offset
    period = var.quota_period
  }

  throttle_settings {
    burst_limit = var.throttle_burst_limit
    rate_limit  = var.throttle_rate_limit
  }
}

# apigatewayv1:013: Implement API key validation for API Gateway methods
resource "aws_api_gateway_api_key" "main" {
  name = "api-key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# apigatewayv1:014: Enable mutual TLS authentication for API Gateway custom domain names
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn

  mutual_tls_authentication {
    truststore_uri     = var.truststore_uri
    truststore_version = var.truststore_version
  }

  security_policy = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# apigatewayv1:015: Implement resource policies for API Gateway APIs
resource "aws_api_gateway_rest_api_policy" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "${aws_api_gateway_rest_api.main.execution_arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ip_ranges
          }
        }
      }
    ]
  })
}

# Deployment resource
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  lifecycle {
    create_before_destroy = true
  }

  # Add explicit dependency on methods and integrations
  depends_on = [
    aws_api_gateway_method.example,
    aws_api_gateway_integration.example
  ]
}

# Example method and integration (you should replace these with your actual methods and integrations)
resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.main.id

  request_validator_id = aws_api_gateway_request_validator.main.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "example"
}