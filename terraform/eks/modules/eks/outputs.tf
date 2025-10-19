output "cluster_name" {
    description = "EKS cluster name"
    value       = aws_eks_cluster.main.name  
}

output "cluster_endpoint" {
    description = "EKS cluster endpoint"
    value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
    description = "Security Group ID attached to the EKS cluster"
    value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
    description = "Security group ID for eks nodes"
    value       = aws_security_group.node.id
}

output "cluster_certificate_authority_data" {
    description = "Base64 encoded certificate data"
    value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_arn" {
    description = "EKS cluster ARN"
    value      = aws_eks_cluster.main.arn
}

output "node_role_arn" {
    description = "EKS node role ARN"
    value       = aws_iam_role.node.arn
}

output "node_role_name" {
    description = "EKS node role name"
    value       = aws_iam_role.node.name
}