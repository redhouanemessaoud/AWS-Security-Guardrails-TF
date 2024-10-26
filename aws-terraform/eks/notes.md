# AWS EKS Security Requirements Implementation Notes

1. eks:001: Enable Network Policy for EKS Clusters
- Implemented in Terraform code using `aws_eks_addon` resource with the VPC CNI addon.

2. eks:002: Encrypt Kubernetes Secrets using AWS KMS Customer Managed Keys (CMKs)
- Implemented in Terraform code within the `aws_eks_cluster` resource using the `encryption_config` block.

3. eks:003: Use Supported Kubernetes Version for EKS Clusters
- Implemented in Terraform code by setting the `version` attribute in the `aws_eks_cluster` resource.

4. eks:004: Disable Public Access to EKS Cluster API Server Endpoint
- Implemented in Terraform code within the `aws_eks_cluster` resource by setting `endpoint_public_access = false`.

5. eks:005: Create EKS Clusters with Private Nodes
- Implemented in Terraform code using `aws_eks_node_group` resource with private subnet IDs.

6. eks:006: Enable EKS Control Plane Logging for All Log Types
- Implemented in Terraform code within the `aws_eks_cluster` resource using the `enabled_cluster_log_types` attribute.

7. eks:007: Disable SSH Access to EKS Node Groups from 0.0.0.0/0
- Implemented in Terraform code within the `aws_eks_node_group` resource by specifying `source_security_group_ids` in the `remote_access` block.

8. eks:008: Enable VPC CNI Network Policy
- Implemented in Terraform code using `aws_eks_addon` resource with the VPC CNI addon.

9. eks:009: Use IAM Roles for Service Accounts (IRSA)
- Implemented in Terraform code using `aws_iam_openid_connect_provider` resource.

10. eks:010: Enable Envelope Encryption for EKS Secrets
- Implemented in Terraform code within the `aws_eks_cluster` resource using the `encryption_config` block.

11. eks:011: Implement Pod Security Policies
- Not directly implemented in Terraform. Pod Security Policies are deprecated in Kubernetes 1.21+. Consider using Pod Security Standards or OPA Gatekeeper instead.

12. eks:012: Enable EKS Add-ons with Managed Updates
- Implemented in Terraform code using `aws_eks_addon` resources for CoreDNS and kube-proxy.

13. eks:013: Implement EKS Cluster Autoscaler
- Implemented in Terraform code using `aws_autoscaling_policy` resource.

14. eks:014: Use EKS Managed Node Groups
- Implemented in Terraform code using `aws_eks_node_group` resource.

15. eks:015: Implement EKS Fargate Profiles for Serverless Workloads
- Implemented in Terraform code using `aws_eks_fargate_profile` resource.

Additional security measures and best practices:
- All configurable parameters are exposed as variables to make the module reusable and flexible.
- The module uses secure defaults, such as disabling public access to the API server and using private subnets for nodes.
- The module assumes that IAM roles, KMS keys, and security groups already exist and requires their ARNs/IDs as input.
- Consider implementing additional access controls and monitoring for the EKS cluster and its associated resources.
- Implement least privilege access principles when defining IAM roles for the cluster, nodes, and Fargate profiles.
- Regularly update the EKS cluster and node groups to the latest supported Kubernetes version.
- Implement proper network segmentation and security group rules to control traffic to and from the EKS cluster.
- Use AWS Config rules or custom scripts to continuously monitor and enforce EKS security best practices.
- Implement proper logging and monitoring solutions, such as Amazon CloudWatch, to track cluster and application metrics and logs.
- Regularly review and audit cluster configurations, policies, and access logs to ensure compliance with security requirements.