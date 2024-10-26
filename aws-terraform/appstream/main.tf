# AppStream 2.0 Fleet Configuration
resource "aws_appstream_fleet" "main" {
  name                   = var.fleet_name
  instance_type          = var.instance_type
  fleet_type             = var.fleet_type
  max_user_duration_in_seconds = var.max_user_duration_in_seconds
  disconnect_timeout_in_seconds = var.disconnect_timeout_in_seconds
  idle_disconnect_timeout_in_seconds = var.idle_disconnect_timeout_in_seconds

  # appstream:002: Disable default Internet access for AppStream fleet streaming instances
  enable_default_internet_access = false

  # appstream:005: Enable encryption for AppStream 2.0 user sessions
  # appstream:006: Use AWS KMS Customer Managed Keys (CMK) for AppStream 2.0 encryption
  stream_view = "ENCRYPTED"
  stream_encryption_key_arn = var.kms_key_arn

  # appstream:009: Configure AppStream 2.0 to use latest streaming protocols
  protocol = "TCP_UDP"

  # appstream:010: Implement network isolation for AppStream 2.0 fleets
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  # appstream:015: Implement AppStream 2.0 resource tagging for enhanced management and security
  tags = var.tags
}

# AppStream 2.0 Stack Configuration
resource "aws_appstream_stack" "main" {
  name         = var.stack_name
  description  = var.stack_description
  display_name = var.stack_display_name

  # appstream:011: Enable AppStream 2.0 user file persistence with encryption
  storage_connectors {
    connector_type = "HOMEFOLDERS"
    resource_identifier = var.home_folder_s3_arn
  }

  # appstream:013: Configure AppStream 2.0 to use SAML 2.0-based authentication
  user_settings {
    action     = "SAML_2_0"
    permission = "ENABLED"
  }

  # appstream:015: Implement AppStream 2.0 resource tagging for enhanced management and security
  tags = var.tags
}

# AppStream 2.0 Fleet-Stack Association
resource "aws_appstream_fleet_stack_association" "main" {
  fleet_name = aws_appstream_fleet.main.name
  stack_name = aws_appstream_stack.main.name
}

# appstream:008: Enable AppStream 2.0 usage reports
resource "aws_appstream_usage_report_subscription" "main" {
  s3_bucket_arn = var.usage_reports_s3_bucket_arn
  schedule      = "DAILY"
}

# appstream:014: Enable AppStream 2.0 application entitlements
resource "aws_appstream_user_stack_association" "main" {
  stack_name  = aws_appstream_stack.main.name
  user_name   = var.user_name
  send_email_notification = true
}

# IAM Policies for AppStream 2.0 (Read-Only and Write)
data "aws_iam_policy_document" "appstream_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "appstream:Describe*",
      "appstream:List*",
      "appstream:Get*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "appstream_write" {
  statement {
    effect = "Allow"
    actions = [
      "appstream:Create*",
      "appstream:Update*",
      "appstream:Delete*",
      "appstream:Start*",
      "appstream:Stop*",
      "appstream:Associate*",
      "appstream:Disassociate*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "appstream_read_only" {
  name        = "AppStreamReadOnlyPolicy"
  description = "Read-only access to AppStream 2.0 resources"
  policy      = data.aws_iam_policy_document.appstream_read_only.json
}

resource "aws_iam_policy" "appstream_write" {
  name        = "AppStreamWritePolicy"
  description = "Write access to AppStream 2.0 resources"
  policy      = data.aws_iam_policy_document.appstream_write.json
}