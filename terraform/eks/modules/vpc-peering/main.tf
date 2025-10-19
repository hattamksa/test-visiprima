##############################
# VPC Peering Connection
##############################
resource "aws_vpc_peering_connection" "eks_to_rds" {
  vpc_id      = var.eks_vpc_id
  peer_vpc_id = var.rds_vpc_id
  auto_accept = true

  # Enable DNS resolution across VPCs
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-to-rds-peering"
    }
  )
}

##############################
# Add route to RDS VPC in EKS private route tables
##############################
resource "aws_route" "eks_to_rds" {
  count                     = length(var.eks_route_tables)
  route_table_id            = var.eks_route_tables[count.index]
  destination_cidr_block    = var.rds_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eks_to_rds.id
}

##############################
# Data source: Get RDS VPC route tables
##############################
data "aws_route_tables" "rds" {
  vpc_id = var.rds_vpc_id
}

##############################
# Data source: Get EKS VPC CIDR
##############################
data "aws_vpc" "eks" {
  id = var.eks_vpc_id
}

##############################
# Add route to EKS VPC in RDS route tables
##############################
resource "aws_route" "rds_to_eks" {
  count                     = length(data.aws_route_tables.rds.ids)
  route_table_id            = tolist(data.aws_route_tables.rds.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.eks.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eks_to_rds.id
}
