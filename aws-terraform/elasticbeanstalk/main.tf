# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "main" {
  name                = var.environment_name
  application         = var.application_name
  solution_stack_name = var.solution_stack_name

  # elasticbeanstalk:001: Enable Managed Platform Updates for Elastic Beanstalk Environments
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = var.managed_actions_start_time
  }

  # elasticbeanstalk:002: Enable Enhanced Health Reporting for Elastic Beanstalk Environments
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  # elasticbeanstalk:003: Stream Elastic Beanstalk Environment Logs to CloudWatch Logs
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  # elasticbeanstalk:004: Use VPC for Elastic Beanstalk Environments
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.subnet_ids)
  }

  # elasticbeanstalk:005: Enable HTTPS for Elastic Beanstalk Environment URLs
  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = var.ssl_certificate_arn
  }

  # elasticbeanstalk:006: Use IAM Instance Profiles for Elastic Beanstalk EC2 Instances
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.instance_profile_name
  }

  # elasticbeanstalk:007: Enable Encryption for Elastic Beanstalk Environment Resources
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp2"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.root_volume_size
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeEncrypted"
    value     = "true"
  }

  # elasticbeanstalk:008: Implement Strict Security Group Rules for Elastic Beanstalk Environments
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.security_group_id
  }

  # elasticbeanstalk:009: Enable X-Ray Tracing for Elastic Beanstalk Applications
  setting {
    namespace = "aws:elasticbeanstalk:xray"
    name      = "XRayEnabled"
    value     = "true"
  }

  # elasticbeanstalk:010: Use Environment Variables for Sensitive Configuration in Elastic Beanstalk
  dynamic "setting" {
    for_each = var.environment_variables
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  # elasticbeanstalk:011: Implement Auto Scaling for Elastic Beanstalk Environments
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.autoscaling_min_size
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.autoscaling_max_size
  }

  # elasticbeanstalk:012: Enable Elastic Beanstalk Managed Updates for RDS Databases
  setting {
    namespace = "aws:rds:dbinstance"
    name      = "HasCoupledDatabase"
    value     = "true"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngineVersion"
    value     = var.rds_engine_version
  }

  # elasticbeanstalk:014: Use Latest Elastic Beanstalk Platform Version
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  # elasticbeanstalk:015: Implement AWS WAF for Elastic Beanstalk Environments
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
}

# AWS WAF WebACL Association
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_elastic_beanstalk_environment.main.endpoint_url
  web_acl_arn  = var.waf_web_acl_arn
}

# S3 Bucket for Elastic Beanstalk Application Versions
resource "aws_s3_bucket" "eb_bucket" {
  bucket = var.eb_bucket_name
}

# elasticbeanstalk:013: Implement Resource-Based Policies for Elastic Beanstalk S3 Buckets
resource "aws_s3_bucket_policy" "eb_bucket_policy" {
  bucket = aws_s3_bucket.eb_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEBAccess"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.eb_bucket.arn,
          "${aws_s3_bucket.eb_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "eb_bucket" {
  bucket = aws_s3_bucket.eb_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "eb_bucket" {
  bucket = aws_s3_bucket.eb_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "eb_bucket" {
  bucket = aws_s3_bucket.eb_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}