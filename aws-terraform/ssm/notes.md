# AWS Systems Manager (SSM) Security Requirements Implementation Notes

1. SSM:001 - Ensure SSM documents are not publicly accessible
   - Implemented in Terraform using `aws_ssm_document` resource with `permissions` block to restrict access to specific account IDs.

2. SSM:002 - Use AWS KMS Customer Managed Keys (CMK) for encrypting SSM parameters
   - Implemented in Terraform using `aws_ssm_parameter` resource with `key_id` attribute set to a KMS key ID.

3. SSM:003 - Enable encryption for Session Manager data in transit
   - Implemented in Terraform using `aws_ssm_document` resource for Session Manager preferences, with encryption enabled.

4. SSM:004 - Enable and encrypt Session Manager logs
   - Implemented in Terraform using `aws_ssm_document` resource for Session Manager preferences, with S3 and CloudWatch logs encryption enabled.

5. SSM:005 - Implement least privilege access for SSM documents and parameters
   - Not directly implemented in Terraform. This requires custom IAM policy implementation based on specific use cases.

6. SSM:006 - Enable AWS Config rules for SSM patch compliance
   - Not implemented in Terraform. AWS Config rules are typically managed separately from SSM resources.

7. SSM:007 - Use secure string parameter type for sensitive data in SSM Parameter Store
   - Implemented in Terraform using `aws_ssm_parameter` resource with `type = "SecureString"`.

8. SSM:008 - Implement version control for SSM documents
   - Implemented in Terraform using `aws_ssm_document` resource with `version_name` attribute.

9. SSM:009 - Configure SSM Agent to use VPC endpoints
   - Not directly implemented in Terraform. VPC endpoints are typically managed separately from SSM resources.

10. SSM:010 - Implement resource tags for SSM managed instances
    - Implemented in Terraform using `aws_ssm_activation` resource with `tags` attribute.

11. SSM:011 - Enable SSM Inventory for managed instances
    - Implemented in Terraform using `aws_ssm_resource_data_sync` resource to set up inventory data collection.

12. SSM:012 - Implement SSM Patch Manager baseline with auto-approval rules
    - Implemented in Terraform using `aws_ssm_patch_baseline` resource with approval rules and filters.

13. SSM:013 - Use SSM Run Command with approval workflow for critical operations
    - Not directly implemented in Terraform. This requires setting up AWS Systems Manager Change Manager, which is typically done through the AWS Console or AWS CLI.

14. SSM:014 - Configure SSM Session Manager to use AWS PrivateLink
    - Not directly implemented in Terraform. AWS PrivateLink configuration is typically managed at the VPC level.

15. SSM:015 - Implement SSM Parameter Store hierarchies for organized secret management
    - Implemented in Terraform using `aws_ssm_parameter` resource with a hierarchical naming convention.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as using SecureString for parameters and enabling encryption for Session Manager.
- The module assumes that KMS keys, S3 buckets, and IAM roles already exist and requires their IDs/ARNs as input.
- Consider implementing additional access controls and monitoring for SSM resources.
- Implement least privilege access principles when defining IAM policies for SSM access.
- Regularly review and audit SSM documents, parameters, and access logs to ensure compliance with security requirements.
- For SSM:005, SSM:006, SSM:009, SSM:013, and SSM:014, additional configurations outside of this Terraform module may be required to fully implement these security measures.