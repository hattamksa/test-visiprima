variable "environment" {
  description = "Environment name"
  type        = string
}

variable "eks_vpc_id" {
  description = "EKS VPC ID"
  type        = string
}

variable "rds_vpc_id" {
  description = "RDS VPC ID"
  type        = string
}

variable "eks_route_tables" {
  description = "EKS private route table IDs"
  type        = list(string)
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