# AWS DynamoDB Security Requirements Implementation Notes

1. dynamodb:001: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB tables
   - Implemented in Terraform code using `server_side_encryption` block in `aws_dynamodb_table` resource.

2. dynamodb:002: Enable Point-in-Time Recovery (PITR) for DynamoDB tables
   - Implemented in Terraform code using `point_in_time_recovery` block in `aws_dynamodb_table` resource.

3. dynamodb:003: Enable deletion protection for DynamoDB tables
   - Implemented in Terraform code by setting `deletion_protection_enabled = true` in `aws_dynamodb_table` resource.

4. dynamodb:004: Configure DynamoDB tables to automatically scale capacity with demand
   - Implemented in Terraform code using `aws_appautoscaling_target` and `aws_appautoscaling_policy` resources for both read and write capacities.

5. dynamodb:005: Include DynamoDB tables in a backup plan
   - Not directly implemented in Terraform. This requires setting up AWS Backup, which is typically done at an account or organizational level.

6. dynamodb:006: Restrict DynamoDB table access to specific AWS accounts or IAM principals
   - Partially implemented by creating read-only and write IAM policies. Specific account or principal restrictions need to be added based on use case.

7. dynamodb:007: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB Accelerator (DAX) clusters
   - Implemented in Terraform code using `server_side_encryption` block in `aws_dax_cluster` resource.

8. dynamodb:008: Enable encryption in transit for DynamoDB Accelerator (DAX) clusters
   - Implemented in Terraform code by setting `cluster_endpoint_encryption_type = "TLS"` in `aws_dax_cluster` resource.

9. dynamodb:009: Deploy DynamoDB Accelerator (DAX) clusters across multiple Availability Zones
   - Implemented in Terraform code by setting `availability_zones` in `aws_dax_cluster` resource.

10. dynamodb:010: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for DynamoDB Global Tables
    - Implemented in Terraform code by specifying `kms_key_arn` for each replica in `aws_dynamodb_global_table` resource.

11. dynamodb:011: Enable Point-in-Time Recovery (PITR) for DynamoDB Global Tables
    - Inherently implemented by enabling PITR on the main table (dynamodb:002). Global tables inherit PITR settings from the main table.

12. dynamodb:012: Implement least privilege access for DynamoDB resources
    - Partially implemented by creating separate read-only and write IAM policies. Further refinement may be needed based on specific use cases.

13. dynamodb:013: Enable DynamoDB Streams for change data capture
    - Implemented in Terraform code by setting `stream_enabled = true` and `stream_view_type = "NEW_AND_OLD_IMAGES"` in `aws_dynamodb_table` resource.

14. dynamodb:014: Implement appropriate Time to Live (TTL) settings for DynamoDB items
    - Implemented in Terraform code using `ttl` block in `aws_dynamodb_table` resource.

15. dynamodb:015: Use VPC endpoints for DynamoDB access
    - Not implemented in this module. VPC endpoints are typically managed at the VPC level and not within the DynamoDB module.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults where possible, such as enabling encryption, PITR, and deletion protection.
- The module assumes that KMS keys already exist and requires their ARNs as input.
- Consider implementing additional monitoring and alerting for DynamoDB tables and DAX clusters.
- Regularly review and audit access patterns and permissions to ensure compliance with security requirements.
- Implement proper error handling and retries in applications using DynamoDB to handle potential throttling or capacity issues.
- Consider using DynamoDB Transactions for operations that require atomicity across multiple items or tables.
- Implement appropriate backup and disaster recovery strategies, including cross-region replication if needed.
- Regularly patch and update DAX clusters to the latest versions to address any security vulnerabilities.