# Security group rule to allow EKS nodes to access RDS
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = var.eks_node_sg_id
  description              = "Allow EKS nodes to access RDS"
}

# Optional: Allow access from EKS cluster security group as well
resource "aws_security_group_rule" "eks_cluster_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = var.eks_cluster_sg_id
  description              = "Allow EKS cluster to access RDS"
}

# Additional security group for pods that need RDS access
resource "aws_security_group" "rds_access" {
  name_prefix = "${var.environment}-rds-access-"
  description = "Security group for pods that need RDS access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.rds_cidr_block]
    description = "Allow outbound to RDS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-access-sg"
    }
  )
}


# Security group rule to allow EKS nodes to access RDS MySQL
resource "aws_security_group_rule" "eks_to_rds_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = var.eks_node_sg_id
  description              = "Allow EKS nodes to access RDS MySQL"
}

# Optional: Allow access from EKS cluster security group as well
resource "aws_security_group_rule" "eks_cluster_to_rds_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = var.eks_cluster_sg_id
  description              = "Allow EKS cluster to access RDS MySQL"
}

# Additional security group for pods that need RDS MySQL access
resource "aws_security_group" "rds_access_mysql" {
  name_prefix = "${var.environment}-rds-mysql-access-"
  description = "Security group for pods that need RDS MySQL access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.rds_cidr_block]
    description = "Allow outbound to RDS MySQL"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-mysql-access-sg"
    }
  )
}

# Allow MySQL (3306) from EKS VPC CIDR via peering
resource "aws_security_group_rule" "eks_vpc_to_rds_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = var.rds_security_group_id
  cidr_blocks       = ["10.10.0.0/16"] # EKS VPC CIDR
  description       = "Allow MySQL from EKS VPC via peering"
}

