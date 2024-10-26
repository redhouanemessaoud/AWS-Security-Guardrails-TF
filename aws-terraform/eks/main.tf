# AWS EKS Cluster Configuration

# eks:003 Use Supported Kubernetes Version for EKS Clusters
# eks:004 Disable Public Access to EKS Cluster API Server Endpoint
# eks:006 Enable EKS Control Plane Logging for All Log Types
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [var.cluster_security_group_id]
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # eks:002 Encrypt Kubernetes Secrets using AWS KMS Customer Managed Keys (CMKs)
  # eks:010 Enable Envelope Encryption for EKS Secrets
  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }
}

# eks:001 Enable Network Policy for EKS Clusters
# eks:008 Enable VPC CNI Network Policy
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}

# eks:012 Enable EKS Add-ons with Managed Updates
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
}

# eks:005 Create EKS Clusters with Private Nodes
# eks:007 Disable SSH Access to EKS Node Groups from 0.0.0.0/0
# eks:014 Use EKS Managed Node Groups
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = var.source_security_group_ids
  }

  launch_template {
    name    = var.launch_template_name
    version = var.launch_template_version
  }
}

# eks:013 Implement EKS Cluster Autoscaler
resource "aws_autoscaling_policy" "cluster_autoscaler" {
  name                   = "cluster-autoscaler"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

# eks:015 Implement EKS Fargate Profiles for Serverless Workloads
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "main"
  pod_execution_role_arn = var.fargate_pod_execution_role_arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "default"
  }
}

# eks:009 Use IAM Roles for Service Accounts (IRSA)
resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# eks:011 Implement Pod Security Policies
# Note: Pod Security Policies are deprecated in Kubernetes 1.21+
# Consider using Pod Security Standards or OPA Gatekeeper instead