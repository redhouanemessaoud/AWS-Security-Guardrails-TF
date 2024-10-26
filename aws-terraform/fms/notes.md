# AWS Firewall Manager Security Requirements Implementation Notes

1. fms:001: Ensure AWS Firewall Manager security policies are compliant
   - Implemented in Terraform code using `aws_fms_policy` resource with configurable options.

2. fms:002: Implement least privilege access for AWS Firewall Manager
   - Partially implemented in Terraform code by creating an IAM role with AWSFMAdminFullAccess policy. Further customization may be needed based on specific requirements.

3. fms:003: Enable AWS Firewall Manager logging
   - Partially implemented in Terraform code by including accounts in the policy. Actual logging configuration needs to be set up separately.

4. fms:004: Implement AWS Firewall Manager policies for WAF
   - Implemented in Terraform code by setting appropriate `security_service_policy_type` and `managed_service_data` in the `aws_fms_policy` resource.

5. fms:005: Implement AWS Firewall Manager policies for Shield Advanced
   - Implemented in Terraform code by setting appropriate `security_service_policy_type` and `managed_service_data` in the `aws_fms_policy` resource.

6. fms:006: Implement AWS Firewall Manager policies for Security Groups
   - Implemented in Terraform code by setting appropriate `security_service_policy_type` and `managed_service_data` in the `aws_fms_policy` resource.

7. fms:007: Regularly review and update AWS Firewall Manager policies
   - Not directly implemented in Terraform. This is a process recommendation that requires manual intervention and regular reviews.

8. fms:008: Implement AWS Firewall Manager policies for Network Firewall
   - Implemented in Terraform code by setting appropriate `security_service_policy_type` and `managed_service_data` in the `aws_fms_policy` resource.

9. fms:009: Configure AWS Firewall Manager notifications
   - Implemented in Terraform code by setting up SNS topic for notifications in the `aws_fms_policy` resource.

10. fms:010: Implement AWS Firewall Manager policies for DNS Firewall
    - Implemented in Terraform code by setting appropriate `security_service_policy_type` and `managed_service_data` in the `aws_fms_policy` resource.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as enabling remediation by default.
- Consider implementing additional access controls and monitoring for Firewall Manager policies.
- Regularly review and audit Firewall Manager policies to ensure compliance with security requirements.
- Implement a process for regularly updating and reviewing Firewall Manager policies (fms:007).
- Ensure that the IAM role created for Firewall Manager has the minimum necessary permissions.
- Consider implementing additional logging and monitoring solutions to complement Firewall Manager logs.