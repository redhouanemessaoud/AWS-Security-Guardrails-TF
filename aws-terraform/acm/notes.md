# AWS ACM Security Requirements Implementation Notes

1. ACM:001: Use secure key algorithms for ACM certificates
   - Implemented in Terraform code using the `key_algorithm` parameter in the `aws_acm_certificate` resource.

2. ACM:002: Set up automated renewal for ACM certificates
   - Automatically handled by ACM for certificates issued through ACM. No additional configuration needed.

3. ACM:003: Enable Certificate Transparency logging for ACM certificates
   - Implemented in Terraform code by setting `certificate_transparency_logging_preference = "ENABLED"` in the `aws_acm_certificate` resource.

4. ACM:004: Avoid wildcard domains in ACM certificates
   - Implemented in Terraform code by using specific domain names in `domain_name` and `subject_alternative_names` variables.

5. ACM:005: Implement 'create before destroy' for ACM certificates
   - Implemented in Terraform code using the `create_before_destroy = true` lifecycle rule in the `aws_acm_certificate` resource.

6. ACM:006: Use ACM Private Certificate Authority for internal services
   - Implemented in Terraform code using the `aws_acmpca_certificate_authority` resource.

7. ACM:007: Implement certificate pinning for critical applications
   - Not directly implementable in Terraform. This is an application-level configuration that needs to be implemented in the application code.

8. ACM:008: Regularly audit and rotate ACM certificates
   - Not directly implementable in Terraform. This requires operational processes and potentially custom scripts or Lambda functions.

9. ACM:009: Use ACM certificates with AWS services that integrate with ACM
   - Partially implemented. The ACM certificate is created and can be referenced by other AWS services. Specific service integrations need to be configured in those service's Terraform resources.

10. ACM:010: Implement access controls for ACM certificate management
    - Implemented in Terraform code by creating IAM policies for read-only and full access to ACM.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults, such as RSA_2048 for the key algorithm.
- For the private CA, a secure key algorithm (RSA_4096) is used by default.
- Consider implementing additional monitoring and alerting for certificate expiration and renewal status.
- Regularly review and audit ACM usage and access patterns.
- Implement least privilege access principles when assigning ACM-related IAM policies to users and roles.
- Consider using ACM Private CA for issuing certificates for internal services to maintain stricter control over certificate issuance.