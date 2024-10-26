# AWS Secrets Manager Security Requirements Implementation Notes

1. secretsmanager:001: Enable automatic rotation for Secrets Manager secrets
   - Implemented in Terraform code using `aws_secretsmanager_secret_rotation` resource.

2. secretsmanager:002: Use AWS KMS Customer Managed Keys (CMK) for Secrets Manager secret encryption
   - Implemented in Terraform code within the `aws_secretsmanager_secret` resource using the `kms_key_id` argument.

3. secretsmanager:003: Implement resource-based policies to restrict access to Secrets Manager secrets
   - Implemented in Terraform code using `aws_secretsmanager_secret_policy` resource.

4. secretsmanager:004: Enable CloudTrail logging for Secrets Manager API calls
   - Not implemented in this module. CloudTrail logging should be enabled at the account level for all services.

5. secretsmanager:005: Implement a process for regular secret auditing and cleanup
   - Not directly implementable in Terraform. This requires operational processes and potentially custom scripts or Lambda functions.

6. secretsmanager:006: Use VPC endpoints for Secrets Manager access within VPCs
   - Not implemented in this module. VPC endpoints should be managed separately from the Secrets Manager configuration.

7. secretsmanager:007: Implement strict IAM policies for Secrets Manager access
   - Partially implemented in Terraform code by creating read and write IAM policies. Actual assignment of these policies to IAM users/roles should be done separately based on specific needs.

8. secretsmanager:008: Enable and configure Secrets Manager secret versions
   - Implemented in Terraform code within the `aws_secretsmanager_secret` resource. Versioning is enabled by default in Secrets Manager.

9. secretsmanager:009: Implement tagging strategy for Secrets Manager secrets
   - Implemented in Terraform code within the `aws_secretsmanager_secret` resource using the `tags` argument.

10. secretsmanager:010: Use Secrets Manager for storing and rotating database credentials
    - Implemented in Terraform code using `aws_secretsmanager_secret_version` resource to store database credentials.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults, such as a 30-day recovery window for secret deletion.
- The module assumes that KMS keys and rotation Lambda functions already exist and requires their ARNs as input.
- Consider implementing additional monitoring and alerting for secret access and changes.
- Regularly review and audit secret policies and access logs to ensure compliance with security requirements.
- Implement least privilege access principles when defining IAM policies for secret access.
- Consider using AWS Config rules to monitor and enforce Secrets Manager configuration compliance.