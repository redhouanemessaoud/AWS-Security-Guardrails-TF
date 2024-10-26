# AWS ELBv2 Secure Configuration

# elbv2:001: Use AWS WAF Web ACL for Application Load Balancers
resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  # elbv2:002: Enable Access Logging for Elastic Load Balancers
  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = true
  }

  # elbv2:003: Configure Application Load Balancers with Strictest Desync Mitigation Mode
  desync_mitigation_mode = "strictest"

  # elbv2:004: Deploy Elastic Load Balancers Across Multiple Availability Zones
  # This is ensured by providing multiple subnet IDs in different AZs

  # elbv2:006: Enable Deletion Protection for Elastic Load Balancers
  enable_deletion_protection = true

  # elbv2:009: Enable Cross-Zone Load Balancing for Network and Gateway Load Balancers
  # This setting is not applicable for ALB, it's enabled by default

  tags = var.tags
}

# elbv2:001: Use AWS WAF Web ACL for Application Load Balancers
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# elbv2:005: Use Secure TLS Configuration for Load Balancer Listeners
# elbv2:007: Configure HTTPS Listeners for Application Load Balancers
# elbv2:008: Use AWS Certificate Manager for Load Balancer SSL/TLS Certificates
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# elbv2:007: Configure HTTPS Listeners for Application Load Balancers (HTTP to HTTPS redirection)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# elbv2:010: Configure Health Checks for Load Balancer Target Groups
resource "aws_lb_target_group" "main" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
}

# elbv2:011: Implement Secure Listener Rules for Application Load Balancers
resource "aws_lb_listener_rule" "secure_path" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/secure/*"]
    }
  }
}

# elbv2:012: Use VPC Security Groups to Control Traffic to Load Balancers
# This is implemented by associating the security group in the aws_lb resource