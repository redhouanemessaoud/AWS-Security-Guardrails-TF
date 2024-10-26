# AWS EventBridge Security Requirements Implementation Notes

1. eventbridge:001: Restrict EventBridge event bus access to known principals
   - Implemented in Terraform code using `aws_cloudwatch_event_bus_policy` resource with a policy that restricts access to specified account IDs.

2. eventbridge:002: Limit cross-account access for EventBridge event buses
   - Implemented in Terraform code using `aws_cloudwatch_event_bus_policy` resource, which allows specifying allowed account IDs.

3. eventbridge:003: Enable event replication for EventBridge global endpoints
   - Implemented in Terraform code using a conditional `aws_cloudwatch_event_bus_policy` resource that allows event replication when enabled.

4. eventbridge:004: Restrict cross-account access for EventBridge schema registries
   - Not implemented in this module as it pertains to schema registries, which are separate from event buses and rules.

5. eventbridge:005: Use AWS KMS Customer Managed Keys (CMK) for EventBridge rule encryption
   - Partially implemented. The `aws_cloudwatch_event_rule` resource is created, but KMS encryption is not directly supported by EventBridge. Encryption happens at the target level.

6. eventbridge:006: Implement least privilege access for EventBridge resources
   - Implemented in Terraform code by creating separate IAM policies for read and write access to EventBridge resources.

7. eventbridge:007: Enable logging for EventBridge API calls
   - Not implemented in this module. AWS CloudTrail logging should be enabled at the account level for all services.

8. eventbridge:008: Use HTTPS endpoints for EventBridge API calls and targets
   - Partially implemented. EventBridge API calls use HTTPS by default. For targets, it depends on the target configuration, which is not fully controlled by this module.

9. eventbridge:009: Implement tagging for EventBridge resources
   - Implemented in Terraform code by adding tags to the `aws_cloudwatch_event_bus` and `aws_cloudwatch_event_rule` resources.

10. eventbridge:010: Use dead-letter queues for failed event processing
    - Implemented in Terraform code using the `dead_letter_config` block in the `aws_cloudwatch_event_target` resource.

11. eventbridge:011: Implement input transformation for sensitive data in events
    - Implemented in Terraform code using the `input_transformer` block in the `aws_cloudwatch_event_target` resource.

12. eventbridge:012: Regularly review and audit EventBridge rules and targets
    - Not directly implementable in Terraform. This is an operational practice that should be part of the organization's security processes.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as enabling dead-letter queues and input transformation.
- Consider implementing additional monitoring and alerting for EventBridge activities.
- Regularly review and update the allowed account IDs and IAM policies to maintain the principle of least privilege.
- Ensure that the targets of EventBridge rules are also secured appropriately.
- Implement a process for regular audits of EventBridge configurations and associated IAM permissions.