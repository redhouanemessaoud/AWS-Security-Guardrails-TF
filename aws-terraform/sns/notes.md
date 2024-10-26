# AWS SNS Security Requirements Implementation Notes

1. SNS:001: Use HTTPS endpoints for SNS subscriptions
   - Implemented in Terraform code using `aws_sns_topic_subscription` resource with protocol set to "https".

2. SNS:002: Enable server-side encryption for SNS topics using KMS CMK
   - Implemented in Terraform code using `aws_sns_topic` resource with `kms_master_key_id` attribute.

3. SNS:003: Implement least privilege access for SNS topics
   - Partially implemented in Terraform code using `aws_sns_topic_policy` resource with a basic policy. Users should customize this policy based on their specific requirements.

4. SNS:004: Enable SNS topic encryption in transit
   - Implemented inherently by using HTTPS endpoints for subscriptions and enabling server-side encryption.

5. SNS:005: Implement SNS access logging
   - Not directly implemented in Terraform. This requires enabling CloudTrail logging for SNS API calls, which is typically done at the account level.

6. SNS:006: Implement SNS message filtering
   - Implemented in Terraform code using `aws_sns_topic_subscription` resource with `filter_policy` attribute.

7. SNS:007: Enable SNS topic tagging
   - Implemented in Terraform code by adding tags to the `aws_sns_topic` resource.

8. SNS:008: Implement SNS dead-letter queues
   - Implemented in Terraform code using `aws_sns_topic_subscription` resource with `redrive_policy` attribute.

9. SNS:009: Implement SNS message attributes for enhanced security
   - Implemented in Terraform code using `aws_sns_topic_subscription` resource with `filter_policy_scope` set to "MessageAttributes".

10. SNS:010: Regularly review and rotate SNS access keys
    - Not directly implemented in Terraform. This is an operational task that should be managed outside of infrastructure code.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure options by default, such as enabling encryption and using HTTPS endpoints.
- The module assumes that KMS keys and SQS queues (for DLQ) already exist and requires their IDs/ARNs as input.
- Consider implementing additional access controls and monitoring for the SNS topics and their associated resources.
- Implement least privilege access principles when defining IAM policies for topic access.
- Regularly review and audit topic policies and access patterns to ensure compliance with security requirements.
- Enable and configure AWS CloudTrail to log SNS API calls for comprehensive auditing and monitoring.