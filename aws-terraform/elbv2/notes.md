# AWS ELBv2 Security Requirements Implementation Notes

1. elbv2:001: Use AWS WAF Web ACL for Application Load Balancers
   - Implemented in Terraform code using `aws_wafv2_web_acl_association` resource.

2. elbv2:002: Enable Access Logging for Elastic Load Balancers
   - Implemented in Terraform code within the `aws_lb` resource using the `access_logs` block.

3. elbv2:003: Configure Application Load Balancers with Strictest Desync Mitigation Mode
   - Implemented in Terraform code within the `aws_lb` resource using `desync_mitigation_mode = "strictest"`.

4. elbv2:004: Deploy Elastic Load Balancers Across Multiple Availability Zones
   - Implemented by providing multiple subnet IDs in different AZs in the `subnets` attribute of the `aws_lb` resource.

5. elbv2:005: Use Secure TLS Configuration for Load Balancer Listeners
   - Implemented in Terraform code within the `aws_lb_listener` resource for HTTPS, using a secure SSL policy.

6. elbv2:006: Enable Deletion Protection for Elastic Load Balancers
   - Implemented in Terraform code within the `aws_lb` resource using `enable_deletion_protection = true`.

7. elbv2:007: Configure HTTPS Listeners for Application Load Balancers
   - Implemented in Terraform code using `aws_lb_listener` resources for both HTTPS and HTTP (with redirection to HTTPS).

8. elbv2:008: Use AWS Certificate Manager for Load Balancer SSL/TLS Certificates
   - Implemented in Terraform code within the HTTPS `aws_lb_listener` resource by specifying the `certificate_arn`.

9. elbv2:009: Enable Cross-Zone Load Balancing for Network and Gateway Load Balancers
   - Not directly applicable for Application Load Balancers as it's enabled by default and cannot be disabled.

10. elbv2:010: Configure Health Checks for Load Balancer Target Groups
    - Implemented in Terraform code within the `aws_lb_target_group` resource using the `health_check` block.

11. elbv2:011: Implement Secure Listener Rules for Application Load Balancers
    - Implemented in Terraform code using `aws_lb_listener_rule` resource. A sample rule for secure path routing is provided.

12. elbv2:012: Use VPC Security Groups to Control Traffic to Load Balancers
    - Implemented by associating the security group in the `aws_lb` resource using the `security_groups` attribute.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as setting the load balancer to internal by default.
- HTTPS is enforced by redirecting HTTP traffic to HTTPS.
- The most up-to-date TLS policy is used for HTTPS listeners.
- Health checks are configured with reasonable defaults but can be customized as needed.
- Consider implementing additional monitoring and alerting for the load balancer using CloudWatch.
- Regularly review and update the WAF rules associated with the load balancer.
- Ensure that the S3 bucket used for access logs has appropriate access controls and encryption.
- Regularly rotate and update SSL/TLS certificates used by the load balancer.
- Implement least privilege access principles when defining IAM policies for managing the load balancer.