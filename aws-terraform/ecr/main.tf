# ECR:001 Enable Encryption at Rest using AWS KMS Customer Managed Key (CMK) for ECR Repositories
# ECR:002 Enable Image Scanning on Push for ECR Repositories
# ECR:003 Configure Tag Immutability for ECR Repositories
# ECR:005 Ensure ECR Repositories are Private
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR:004 Implement Lifecycle Policies for ECR Repositories
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR:006 Implement Least Privilege Access for ECR Repositories
# ECR:010 Implement ECR Repository Policies
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LimitedPullAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_pull_principals
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid    = "LimitedPushAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_push_principals
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# ECR:008 Implement Cross-Region Replication for Critical ECR Repositories
resource "aws_ecr_replication_configuration" "main" {
  replication_configuration {
    rule {
      destination {
        region      = var.replication_region
        registry_id = var.replication_registry_id
      }
    }
  }
}

# ECR:012 Implement ECR Image Tagging Strategy
resource "aws_ecr_repository" "tagged" {
  name                 = "${var.repository_name}-tagged"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

# ECR:014 Implement ECR Pull Through Cache Repositories Securely
resource "aws_ecr_pull_through_cache_rule" "main" {
  ecr_repository_prefix = var.pull_through_cache_prefix
  upstream_registry_url = var.upstream_registry_url
}

# ECR:015 Enable ECR Scan Findings Export to Security Hub
resource "aws_ecr_registry_scanning_configuration" "main" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}