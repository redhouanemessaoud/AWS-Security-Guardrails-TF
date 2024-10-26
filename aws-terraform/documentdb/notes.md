# AWS DocumentDB Security Requirements Implementation Notes

1. documentdb:001: Enable encryption at rest for DocumentDB clusters using AWS KMS Customer Managed Keys (CMK)
   - Implemented in Terraform code using `storage_encrypted = true` and `kms_key_id` in the `aws_docdb_cluster` resource.

2. documentdb:002: Enable automatic backups for DocumentDB clusters with adequate retention period
   - Implemented in Terraform code using `backup_retention_period` in the `aws_docdb_cluster` resource.

3. documentdb:003: Disable public access for DocumentDB manual cluster snapshots
   - Not directly implementable in Terraform. This is a feature of RDS that applies to manual snapshots, which are created outside of Terraform.

4. documentdb:004: Enable log export feature for DocumentDB clusters
   - Implemented in Terraform code using `enabled_cloudwatch_logs_exports` in the `aws_docdb_cluster` resource.

5. documentdb:005: Enable deletion protection for DocumentDB clusters
   - Implemented in Terraform code using `deletion_protection` in the `aws_docdb_cluster` resource.

6. documentdb:006: Enable audit logging for DocumentDB clusters
   - Implemented in Terraform code using `parameter` block in the `aws_docdb_cluster_parameter_group` resource.

7. documentdb:007: Enforce TLS connections for DocumentDB clusters
   - Implemented in Terraform code using `parameter` block in the `aws_docdb_cluster_parameter_group` resource.

8. documentdb:008: Enable encryption at rest for DocumentDB global clusters
   - Partially implemented through documentdb:001. Global clusters are not directly supported in Terraform for DocumentDB.

9. documentdb:009: Implement least privilege access for DocumentDB clusters
   - Partially implemented by creating separate read-only and write IAM policies. Actual assignment of these policies to users/roles is not included as it's use-case dependent.

10. documentdb:010: Enable enhanced monitoring for DocumentDB clusters
    - Implemented in Terraform code using `monitoring_interval` and `monitoring_role_arn` in the `aws_docdb_cluster_instance` resource.

11. documentdb:011: Use latest TLS version for DocumentDB connections
    - Implemented by enabling TLS. DocumentDB automatically uses the latest supported TLS version.

12. documentdb:012: Implement secure password policies for DocumentDB users
    - Not directly implementable in Terraform. This is typically managed through database-level configurations or organizational policies.

13. documentdb:013: Restrict network access to DocumentDB clusters
    - Implemented in Terraform code using `vpc_security_group_ids` and `subnet_ids` in the `aws_docdb_cluster` resource.

14. documentdb:014: Enable automatic minor version upgrades for DocumentDB clusters
    - Implemented in Terraform code using `auto_minor_version_upgrade` in the `aws_docdb_cluster_instance` resource.

15. documentdb:015: Implement regular patching schedule for DocumentDB clusters
    - Not directly implementable in Terraform. This is typically managed through operational processes and maintenance windows.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure options by default, such as enabling encryption, deletion protection, and TLS.
- The module assumes that KMS keys, VPC security groups, and subnets already exist and requires their IDs/ARNs as input.
- Consider implementing additional access controls and monitoring for the DocumentDB cluster and its associated resources.
- Implement least privilege access principles when defining IAM policies for cluster access.
- Regularly review and audit cluster configurations and access logs to ensure compliance with security requirements.
- Use secrets management solutions for storing and rotating database credentials.