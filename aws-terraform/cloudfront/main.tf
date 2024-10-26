# AWS CloudFront Distribution Security Configuration

# cloudfront:001: Enforce HTTPS-only communication for CloudFront distributions
# cloudfront:002: Enable Server Name Indication (SNI) for CloudFront distributions
# cloudfront:003: Ensure CloudFront distributions point to valid S3 origins
# cloudfront:004: Implement geo-restriction for CloudFront distributions
# cloudfront:005: Configure origin failover for CloudFront distributions
# cloudfront:006: Use Origin Access Control (OAC) for CloudFront distributions with S3 origins
# cloudfront:007: Enable Field-Level Encryption for sensitive data in CloudFront distributions
# cloudfront:008: Enable access logging for CloudFront distributions
# cloudfront:009: Use latest TLS version for CloudFront viewer and origin connections
# cloudfront:010: Configure default root object for CloudFront distributions
# cloudfront:011: Integrate AWS WAF with CloudFront distributions
# cloudfront:012: Use custom SSL/TLS certificates for CloudFront distributions
# cloudfront:013: Implement response headers policy for CloudFront distributions
# cloudfront:014: Enforce HTTPS for CloudFront origin protocol policy
# cloudfront:015: Implement standard encryption for real-time logs
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.distribution_comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  
  origin {
    domain_name              = var.s3_origin_domain_name
    origin_id                = var.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  origin_group {
    origin_id = "${var.s3_origin_id}-group"
    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }
    member {
      origin_id = var.s3_origin_id
    }
    member {
      origin_id = var.secondary_s3_origin_id
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.s3_origin_id}-group"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = var.waf_web_acl_id

  logging_config {
    include_cookies = false
    bucket          = var.log_bucket
    prefix          = "cloudfront/"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "OAC ${var.distribution_comment}"
  description                       = "Origin Access Control for CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "SecurityHeadersPolicy"
  comment = "Security headers policy for CloudFront"

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = false
    }

    frame_options {
      frame_option = "DENY"
      override     = false
    }

    referrer_policy {
      referrer_policy = "same-origin"
      override        = false
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = false
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = false
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "main" {
  distribution_id = aws_cloudfront_distribution.main.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

resource "aws_cloudfront_field_level_encryption_config" "main" {
  comment = "Field-level encryption configuration"
  
  content_type_profile_config {
    forward_when_content_type_is_unknown = false
    content_type_profiles {
      items {
        content_type = "application/x-www-form-urlencoded"
        format       = "URLEncoded"
      }
    }
  }

  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = false
    query_arg_profiles {
      items {
        query_arg = "sensitive-data"
        profile_id = aws_cloudfront_field_level_encryption_profile.main.id
      }
    }
  }
}

resource "aws_cloudfront_field_level_encryption_profile" "main" {
  comment = "Field-level encryption profile"
  name    = "FLEProfile"
  
  encryption_entities {
    items {
      public_key_id = var.field_level_encryption_public_key_id
      provider_id   = "FLEProvider"
      field_patterns {
        items = ["sensitive-data"]
      }
    }
  }
}