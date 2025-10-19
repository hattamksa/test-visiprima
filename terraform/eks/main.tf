terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-hatta-state-bucket"
    key            = "eks/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  environment = terraform.workspace == "default" ? "staging" : terraform.workspace
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
  
  # Validate workspace
  validate_workspace = (
    contains(["staging", "production"], local.environment) 
    ? local.environment 
    : file("ERROR: Invalid workspace. Please use 'staging' or 'production'")
  )
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  environment         = local.environment
  vpc_cidr            = var.vpc_cidr[local.environment]
  availability_zones  = var.availability_zones
  project_name        = var.project_name
  
  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  environment        = local.environment
  cluster_name       = "${var.project_name}-${local.environment}"
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  node_groups = var.node_groups[local.environment]
  
  tags = local.common_tags
}

# VPC Peering to RDS
module "vpc_peering" {
  source = "./modules/vpc-peering"
  
  environment       = local.environment
  eks_vpc_id        = module.vpc.vpc_id
  rds_vpc_id        = var.rds_vpc_id[local.environment]
  eks_route_tables  = module.vpc.private_route_table_ids
  rds_cidr_block    = var.rds_vpc_cidr[local.environment]
  
  tags = local.common_tags
}

# Security Group Rules for RDS Access
module "security_groups" {
  source = "./modules/security-groups"
  
  environment          = local.environment
  vpc_id               = module.vpc.vpc_id
  eks_cluster_sg_id    = module.eks.cluster_security_group_id
  eks_node_sg_id       = module.eks.node_security_group_id
  rds_security_group_id = var.rds_security_group_id[local.environment]
  rds_cidr_block       = var.rds_vpc_cidr[local.environment]
  
  tags = local.common_tags
}