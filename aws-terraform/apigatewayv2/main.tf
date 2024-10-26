# Main Terraform configuration for AWS API Gateway V2

# apigatewayv2:001: Enable access logging for API Gateway V2
resource "aws_apigatewayv2_api" "main" {
  name          = var.api_name
  protocol_type = var.protocol_type

  # apigatewayv2:004: Enable encryption in transit for API Gateway V2
  disable_execute_api_endpoint = true
}

# apigatewayv2:001: Enable access logging for API Gateway V2
resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = var.stage_name

  access_log_settings {
    destination_arn = var.cloudwatch_log_group_arn
    format          = var.access_log_format
  }

  # apigatewayv2:009: Enable detailed CloudWatch metrics for API Gateway V2
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }

  # apigatewayv2:005: Implement throttling for API Gateway V2
  route_settings {
    route_key                = "$default"
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }
}

# apigatewayv2:002: Configure authorizers for API Gateway V2
resource "aws_apigatewayv2_authorizer" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = var.authorizer_type
  identity_sources = var.identity_sources
  name             = var.authorizer_name

  jwt_configuration {
    audience = var.jwt_audience
    issuer   = var.jwt_issuer
  }
}

# apigatewayv2:003: Specify authorization type for all API Gateway V2 routes
resource "aws_apigatewayv2_route" "main" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = var.route_key

  authorization_type = var.route_authorization_type
  authorizer_id      = aws_apigatewayv2_authorizer.main.id
}

# apigatewayv2:006: Enable AWS WAF for API Gateway V2
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_apigatewayv2_stage.main.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# apigatewayv2:007: Implement API Gateway V2 usage plans and API keys
resource "aws_apigatewayv2_api_key" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = var.api_key_name
}

# apigatewayv2:008: Configure cross-origin resource sharing (CORS) for API Gateway V2
resource "aws_apigatewayv2_api" "cors" {
  name          = "${var.api_name}-cors"
  protocol_type = var.protocol_type

  cors_configuration {
    allow_headers = var.cors_allow_headers
    allow_methods = var.cors_allow_methods
    allow_origins = var.cors_allow_origins
    max_age       = var.cors_max_age
  }
}

# apigatewayv2:011: Configure custom domain names with TLS certificates for API Gateway V2
resource "aws_apigatewayv2_domain_name" "main" {
  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# apigatewayv2:012: Implement request validation for API Gateway V2
resource "aws_apigatewayv2_model" "main" {
  api_id       = aws_apigatewayv2_api.main.id
  content_type = "application/json"
  name         = var.model_name
  schema       = var.model_schema
}

# apigatewayv2:013: Configure appropriate timeouts for API Gateway V2 integrations
resource "aws_apigatewayv2_integration" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = var.integration_type

  connection_type      = var.connection_type
  integration_method   = var.integration_method
  integration_uri      = var.integration_uri
  timeout_milliseconds = var.integration_timeout
}

# apigatewayv2:014: Implement API caching for API Gateway V2
resource "aws_apigatewayv2_stage" "cached" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "${var.stage_name}-cached"

  cache_cluster_enabled = true
  cache_cluster_size    = var.cache_cluster_size
}

# apigatewayv2:015: Configure stage variables for API Gateway V2
resource "aws_apigatewayv2_stage" "with_variables" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "${var.stage_name}-with-variables"

  stage_variables = var.stage_variables
}