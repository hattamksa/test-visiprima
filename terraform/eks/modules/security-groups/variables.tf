variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "EKS VPC ID"
  type        = string
}

variable "eks_cluster_sg_id" {
  description = "EKS cluster security group ID"
  type        = string
}

variable "eks_node_sg_id" {
  description = "EKS node security group ID"
  type        = string
}

variable "rds_security_group_id" {
  description = "RDS security group ID"
  type        = string
}

variable "rds_cidr_block" {
  description = "RDS VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}