# ACM:001: Use secure key algorithms for ACM certificates
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # ACM:003: Enable Certificate Transparency logging for ACM certificates
  certificate_transparency_logging_preference = "ENABLED"

  # ACM:004: Avoid wildcard domains in ACM certificates
  subject_alternative_names = var.subject_alternative_names

  key_algorithm = var.key_algorithm

  # ACM:005: Implement 'create before destroy' for ACM certificates
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# ACM:002: Set up automated renewal for ACM certificates
# ACM automatically renews certificates. No additional configuration needed.

# ACM:006: Use ACM Private Certificate Authority for internal services
resource "aws_acmpca_certificate_authority" "private_ca" {
  count = var.create_private_ca ? 1 : 0

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.private_ca_common_name
    }
  }

  permanent_deletion_time_in_days = 7
  type                            = "ROOT"

  tags = var.tags
}

# ACM:009: Use ACM certificates with AWS services that integrate with ACM
# This is handled by associating the ACM certificate with supported services in their respective resource configurations.

# ACM:010: Implement access controls for ACM certificate management
data "aws_iam_policy_document" "acm_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "acm:ListTagsForCertificate",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "acm_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "acm:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "acm_read_only" {
  name        = "ACMReadOnlyPolicy"
  path        = "/"
  description = "ACM read-only access policy"
  policy      = data.aws_iam_policy_document.acm_read_only.json
}

resource "aws_iam_policy" "acm_full_access" {
  name        = "ACMFullAccessPolicy"
  path        = "/"
  description = "ACM full access policy"
  policy      = data.aws_iam_policy_document.acm_full_access.json
}