# Route 53 Terraform Module

# route53:001: Enable Query Logging for Route 53 Public Hosted Zones
resource "aws_route53_query_log" "main" {
  count = var.enable_query_logging ? 1 : 0

  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
  zone_id                  = aws_route53_zone.main.zone_id
}

# route53:002: Enable Transfer Lock for Route 53 Domains
# Note: This is handled at the domain registrar level and cannot be directly implemented in Terraform

# route53:003: Enable Privacy Protection for Route 53 Domains
# Note: This is handled at the domain registrar level and cannot be directly implemented in Terraform

# route53:005: Enable DNSSEC Signing for Route 53 Public Hosted Zones
resource "aws_route53_key_signing_key" "main" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = var.kms_key_arn
  name                       = var.key_signing_key_name
}

resource "aws_route53_hosted_zone_dnssec" "main" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id = aws_route53_zone.main.id
}

# route53:009: Use Private Hosted Zones for Internal DNS Resolution
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  dynamic "vpc" {
    for_each = var.is_private_zone ? [1] : []
    content {
      vpc_id = var.vpc_id
    }
  }
}

# route53:010: Implement Health Checks for DNS Failover
resource "aws_route53_health_check" "main" {
  count = var.enable_health_check ? 1 : 0

  fqdn              = var.health_check_fqdn
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_resource_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_request_interval

  tags = var.tags
}

# IAM Policies for least privilege access (route53:006)
data "aws_iam_policy_document" "route53_read_only" {
  statement {
    actions = [
      "route53:Get*",
      "route53:List*",
      "route53:TestDNSAnswer"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "route53_write" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:CreateHostedZone",
      "route53:DeleteHostedZone",
      "route53:UpdateHostedZoneComment"
    ]
    resources = [aws_route53_zone.main.arn]
  }
}

resource "aws_iam_policy" "route53_read_only" {
  name        = "route53-read-only"
  description = "Route 53 read-only access"
  policy      = data.aws_iam_policy_document.route53_read_only.json
}

resource "aws_iam_policy" "route53_write" {
  name        = "route53-write"
  description = "Route 53 write access"
  policy      = data.aws_iam_policy_document.route53_write.json
}