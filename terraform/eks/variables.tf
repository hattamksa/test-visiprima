variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "VPC CIDR blocks per environment"
  type        = map(string)
  default = {
    default    = "10.1.0.0/16"  # Default will use staging config
    staging    = "10.1.0.0/16"
    production = "10.2.0.0/16"
  }
}

variable "node_groups" {
  description = "EKS node group configurations per environment"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
  }))
  default = {
    staging = {
      desired_size   = 2
      min_size       = 1
      max_size       = 4
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
    }
    production = {
      desired_size   = 3
      min_size       = 2
      max_size       = 10
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 100
    }
  }
}

variable "rds_vpc_id" {
  description = "RDS VPC ID per environment"
  type        = map(string)
  default = {
    staging    = "vpc-xxxxxxxx"
    production = "vpc-yyyyyyyy"
  }
}

variable "rds_vpc_cidr" {
  description = "RDS VPC CIDR blocks per environment"
  type        = map(string)
  default = {
    staging    = "10.0.0.0/16"
    production = "10.3.0.0/16"
  }
}

variable "rds_security_group_id" {
  description = "RDS security group ID per environment"
  type        = map(string)
  default = {
    staging    = "sg-xxxxxxxx"
    production = "sg-yyyyyyyy"
  }
}