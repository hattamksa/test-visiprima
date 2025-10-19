output "rds_access_security_group_id" {
  description = "Security group ID for pods that need RDS access"
  value       = aws_security_group.rds_access.id
}