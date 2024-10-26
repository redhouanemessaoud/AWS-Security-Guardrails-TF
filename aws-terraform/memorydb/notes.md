# AWS MemoryDB Security Requirements Implementation Notes

1. memorydb:001: Enable encryption in transit for MemoryDB clusters
   - Implemented in Terraform code using `tls_enabled = true` in the `aws_memorydb_cluster` resource.

2. memorydb:002: Enable encryption at rest for MemoryDB clusters using AWS KMS Customer Managed Keys (CMKs)
   - Implemented in Terraform code using `kms_key_arn` in the `aws_memorydb_cluster` resource.

3. memorydb:003: Enable encryption for MemoryDB snapshots using AWS KMS Customer Managed Keys (CMKs)
   - Implemented in Terraform code using `kms_key_arn` in the `aws_memorydb_snapshot` resource.

4. memorydb:004: Configure MemoryDB clusters to use private subnets only
   - Implemented in Terraform code by using `subnet_group_name` in the `aws_memorydb_cluster` resource. The subnet group should be created separately and contain only private subnets.

5. memorydb:005: Implement least privilege access for MemoryDB clusters
   - Partially implemented in Terraform code by creating two IAM policies: one for read-only access and another for write access. Users should apply these policies as needed to follow the principle of least privilege.

6. memorydb:006: Enable automatic failover for MemoryDB clusters
   - Implemented inherently by setting `num_replicas_per_shard > 0` in the `aws_memorydb_cluster` resource.

7. memorydb:007: Configure security groups for MemoryDB clusters to restrict inbound traffic
   - Partially implemented by accepting `security_group_ids` as an input variable. The actual security group rules should be defined separately to allow only necessary inbound traffic.

8. memorydb:008: Enable Multi-AZ deployment for MemoryDB clusters
   - Implemented inherently by setting `num_replicas_per_shard > 0` in the `aws_memorydb_cluster` resource, assuming the subnet group spans multiple AZs.

9. memorydb:009: Implement regular backups for MemoryDB clusters
   - Implemented in Terraform code using `aws_memorydb_snapshot` resource and configuring `snapshot_retention_limit` and `snapshot_window` in the `aws_memorydb_cluster` resource.

10. memorydb:010: Enable MemoryDB event notifications
    - Implemented in Terraform code using `aws_memorydb_event_subscription` resource.

11. memorydb:011: Implement MemoryDB parameter groups with secure configurations
    - Implemented in Terraform code using `aws_memorydb_parameter_group` resource with some example secure configurations.

12. memorydb:012: Use latest MemoryDB engine version
    - Implemented in Terraform code by setting `engine_version` and enabling `auto_minor_version_upgrade` in the `aws_memorydb_cluster` resource.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure options by default, such as enabling encryption and setting a snapshot retention period.
- The module assumes that KMS keys, subnet groups, security groups, and SNS topics already exist and requires their IDs/ARNs as input.
- Consider implementing additional monitoring and alerting for the MemoryDB cluster and its associated resources.
- Regularly review and update the engine version to ensure the latest security patches are applied.
- Implement proper network segmentation and use VPC endpoints for added security when accessing MemoryDB from within the VPC.
- Regularly audit and rotate access keys and review IAM policies associated with MemoryDB access.