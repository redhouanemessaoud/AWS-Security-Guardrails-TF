# AWS SQS Security Requirements Implementation Notes

1. SQS:001: Enable Server-Side Encryption with AWS KMS for SQS Queues
   - Implemented in Terraform code using `kms_master_key_id` and `kms_data_key_reuse_period_seconds` in the `aws_sqs_queue` resource.

2. SQS:002: Restrict SQS Queue Access to Specific AWS Accounts or Services
   - Implemented in Terraform code using the `policy` attribute in the `aws_sqs_queue` resource, which restricts access to specified AWS accounts.

3. SQS:003: Implement Least Privilege Access for SQS Queues
   - Implemented in Terraform code by creating separate read and write IAM policies (`aws_iam_policy` resources) with minimal required permissions.
   - The queue policy in the `aws_sqs_queue` resource also follows the principle of least privilege.

4. SQS:004: Enable Dead-Letter Queues for SQS
   - Implemented in Terraform code by creating a separate dead-letter queue (`aws_sqs_queue` resource for DLQ) and configuring the main queue to use it via the `redrive_policy` attribute.

5. SQS:005: Implement SQS Queue Access Logging
   - Not directly implemented in Terraform. CloudWatch Logs for SQS are not natively supported. Consider using CloudTrail for API-level logging of SQS actions.

6. SQS:006: Use VPC Endpoints for SQS Access
   - Not implemented in this module as VPC endpoints are typically managed separately from the SQS resource itself.

7. SQS:007: Implement Message Retention Period for SQS Queues
   - Implemented in Terraform code using the `message_retention_seconds` attribute in the `aws_sqs_queue` resource.

8. SQS:008: Enable Server-Side Encryption in Transit for SQS
   - Implemented by default in AWS SQS. All communication uses HTTPS (TLS) by default.

9. SQS:009: Implement SQS Queue Tagging
   - Implemented in Terraform code using the `tags` attribute in the `aws_sqs_queue` resource.

10. SQS:010: Configure SQS Queue Alarms
    - Implemented in Terraform code using `aws_cloudwatch_metric_alarm` resources for queue depth and oldest message age.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as enabling encryption and setting reasonable message retention periods.
- The module assumes that KMS keys and SNS topics for alarms already exist and requires their IDs/ARNs as input.
- Consider implementing additional monitoring and alerting based on specific use cases and requirements.
- Regularly review and audit queue policies and access patterns to ensure compliance with security requirements.
- For FIFO queues, content-based deduplication is configurable but disabled by default.
- The visibility timeout, maximum message size, and other queue attributes are configurable to suit different use cases while maintaining security.