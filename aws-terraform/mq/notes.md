# AWS MQ Security Requirements Implementation Notes

1. mq:001: Enable automatic minor version upgrades for Amazon MQ brokers
   - Implemented in Terraform code using `auto_minor_version_upgrade = true` in the `aws_mq_broker` resource.

2. mq:002: Enable audit logging for Amazon MQ brokers
   - Implemented in Terraform code using `logs { audit = true }` in the `aws_mq_broker` resource.

3. mq:003: Use AWS KMS Customer Managed Key (CMK) for Amazon MQ broker encryption
   - Implemented in Terraform code using `encryption_options` block in the `aws_mq_broker` resource.

4. mq:004: Disable public accessibility for Amazon MQ brokers
   - Implemented in Terraform code using `publicly_accessible = false` in the `aws_mq_broker` resource.

5. mq:005: Enable general logging for Amazon MQ brokers
   - Implemented in Terraform code using `logs { general = true }` in the `aws_mq_broker` resource.

6. mq:006: Keep Amazon MQ brokers updated to the latest major version
   - Partially implemented by allowing user to specify `engine_version` as an input variable. Regular updates would require manual intervention or additional automation outside of Terraform.

7. mq:007: Use VPC peering or AWS PrivateLink for Amazon MQ broker access
   - Not directly implemented in Terraform. This requires additional networking configuration outside the scope of this module.

8. mq:008: Implement least privilege access for Amazon MQ brokers
   - Implemented in Terraform code by creating separate read and write IAM policies for Amazon MQ access.

9. mq:009: Enable encryption in transit for Amazon MQ brokers
   - Implemented in Terraform code by configuring SSL context in the `aws_mq_configuration` resource.

10. mq:010: Configure Amazon MQ brokers in a multi-AZ deployment
    - Implemented in Terraform code using `deployment_mode = "ACTIVE_STANDBY_MULTI_AZ"` in the `aws_mq_broker` resource.

11. mq:011: Implement Amazon MQ broker network access control
    - Partially implemented by allowing user to specify `security_group_ids` as an input variable. Detailed network ACL configuration would require additional resources outside the scope of this module.

12. mq:012: Enable CloudWatch monitoring for Amazon MQ brokers
    - Implemented in Terraform code by creating a CloudWatch metric alarm for CPU utilization.

13. mq:013: Implement message persistence for Amazon MQ brokers
    - Implemented in Terraform code by including `<forcePersistencyPlugin/>` in the broker configuration.

14. mq:014: Use strong authentication mechanisms for Amazon MQ broker access
    - Implemented in Terraform code by allowing user to specify admin username and password. For enhanced security, consider integrating with LDAP or other external authentication systems.

15. mq:015: Regularly rotate Amazon MQ broker credentials
    - Not directly implemented in Terraform. This requires a process outside of Terraform to regularly update the `admin_username` and `admin_password` variables and apply the changes.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as disabling public accessibility and enabling encryption.
- The module assumes that KMS keys, security groups, and SNS topics already exist and requires their IDs/ARNs as input.
- Consider implementing additional monitoring and alerting for the MQ broker and its associated resources.
- Regularly review and audit broker configurations and access logs to ensure compliance with security requirements.
- Implement network segmentation and use private subnets for deploying MQ brokers.
- Consider using AWS Secrets Manager or AWS Systems Manager Parameter Store for managing sensitive information like passwords and connection strings.