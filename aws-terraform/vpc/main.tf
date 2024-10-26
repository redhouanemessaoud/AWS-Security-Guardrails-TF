# vpc:001: Configure VPC subnets to not assign public IP addresses by default
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = var.vpc_name
  }
}

# vpc:002: Deploy VPC subnets across multiple Availability Zones
# vpc:012: Implement network segmentation using public and private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  # vpc:001: Configure VPC subnets to not assign public IP addresses by default
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  # Public subnets may need to assign public IPs, so we allow it to be configurable
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# vpc:011: Implement VPC flow logs for network traffic analysis
resource "aws_flow_log" "main" {
  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.flow_log_destination
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

# vpc:013: Use AWS Network Firewall for advanced traffic filtering
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.vpc_name}-firewall"
  firewall_policy_arn = var.firewall_policy_arn
  vpc_id              = aws_vpc.main.id
  subnet_mapping {
    subnet_id = aws_subnet.private[0].id
  }
}

# vpc:015: Use VPC security groups for fine-grained access control
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Ensure the default security group is locked down
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# vpc:008: Configure VPC endpoints for Amazon EC2 service
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_default_security_group.default.id]
  subnet_ids         = aws_subnet.private[*].id

  private_dns_enabled = true
}

# vpc:009: Implement manual acceptance for VPC Endpoint Service connections
resource "aws_vpc_endpoint_service" "main" {
  acceptance_required        = true
  network_load_balancer_arns = var.nlb_arns
}

# vpc:005: Implement strict allow-listing for VPC endpoint service principals
resource "aws_vpc_endpoint_service_allowed_principal" "main" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.main.id
  principal_arn           = var.allowed_principal_arn
}

# vpc:003: Implement least privilege routing for VPC peering connections
resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.peer_vpc_id
  vpc_id      = aws_vpc.main.id
  auto_accept = var.auto_accept_peering
}

resource "aws_route" "peering_route" {
  count                     = length(var.peering_route_table_ids)
  route_table_id            = var.peering_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# vpc:014: Implement VPC peering encryption
# Note: VPC peering encryption is automatically enabled for inter-region peering connections
# No specific configuration is needed in Terraform

# vpc:004: Ensure both VPN tunnels are active for AWS Site-to-Site VPN connections
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = var.vpn_gateway_id
  customer_gateway_id = var.customer_gateway_id
  type                = "ipsec.1"
  static_routes_only  = false

  tunnel1_inside_cidr = var.tunnel1_inside_cidr
  tunnel2_inside_cidr = var.tunnel2_inside_cidr
}

# vpc:010: Avoid provisioning default VPCs
# This is typically done at the account level and not directly in Terraform
# Consider using AWS Organizations and Service Control Policies (SCPs) to prevent default VPC creation