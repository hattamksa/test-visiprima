# EKS Terraform Configuration

This Terraform configuration creates an Amazon EKS cluster with VPC peering to RDS.

## Features

- **Multi-environment support**: Uses Terraform workspaces for staging and production
- **ECR Integration**: Nodes have IAM permissions to pull images from Amazon ECR
- **VPC Peering**: Establishes private network connectivity between EKS and RDS VPCs
- **High Availability**: Multi-AZ deployment with NAT Gateways per availability zone
- **Security**: Private subnets for EKS nodes, proper security group configurations

## Architecture

```
EKS VPC (10.1.0.0/16 - staging, 10.2.0.0/16 - production)
├── Public Subnets (3 AZs)
│   ├── Internet Gateway
│   └── NAT Gateways
└── Private Subnets (3 AZs)
    ├── EKS Control Plane
    ├── EKS Worker Nodes
    └── VPC Peering to RDS VPC
```

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0
3. Existing RDS infrastructure (from `terraform/rds/`)
4. S3 bucket for Terraform state
5. DynamoDB table for state locking

## Directory Structure

```
terraform/eks/
├── main.tf                      # Root module
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example variable values
├── README.md                    # This file
└── modules/
    ├── vpc/                     # VPC module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/                     # EKS cluster module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc-peering/            # VPC peering module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── security-groups/        # Security groups for RDS access
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Setup Instructions

### 1. Configure Backend

Update the S3 backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "my-terraform-hatta-state-bucket"
  key            = "eks/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### 2. Configure Variables

Copy the example file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `rds_vpc_id`: Get from RDS Terraform outputs
- `rds_vpc_cidr`: Get from RDS Terraform outputs
- `rds_security_group_id`: Get from RDS Terraform outputs

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Create Workspaces

```bash
# Create staging workspace
terraform workspace new staging

# Create production workspace
terraform workspace new production
```

### 5. Deploy Staging Environment

```bash
# Switch to staging workspace
terraform workspace select staging

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 6. Deploy Production Environment

```bash
# Switch to production workspace
terraform workspace select production

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Configuration Details

### Node Group Configuration

**Staging:**
- Instance Type: t3.medium
- Min Size: 1
- Desired Size: 2
- Max Size: 4
- Disk Size: 50 GB

**Production:**
- Instance Type: t3.large
- Min Size: 2
- Desired Size: 3
- Max Size: 10
- Disk Size: 100 GB

### IAM Permissions

EKS nodes have the following permissions:
- `AmazonEKSWorkerNodePolicy`: Required for EKS worker nodes
- `AmazonEKS_CNI_Policy`: Required for pod networking
- `AmazonEC2ContainerRegistryReadOnly`: Pull images from ECR
- Custom ECR policy: Additional ECR permissions

### Security Groups

1. **Cluster Security Group**: Controls access to EKS API server
2. **Node Security Group**: Controls traffic between nodes and pods
3. **RDS Access Security Group**: Allows pods to connect to RDS

### VPC Peering

- Automatic peering connection between EKS and RDS VPCs
- Routes configured in both VPCs for bidirectional communication
- Security group rules allow EKS nodes to access RDS on port 5432

## Accessing the Cluster

After deployment, configure kubectl:

```bash
# Get the kubectl configuration command from outputs
terraform output configure_kubectl

# Or run directly
aws eks update-kubeconfig --region us-east-1 --name myapp-staging
```

Verify access:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Testing RDS Connectivity

Deploy a test pod to verify RDS connectivity:

```bash
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- bash

# Inside the pod, test connection
psql -h <rds-endpoint> -U <username> -d <database>
```

## Outputs

After applying, you'll get:
- `cluster_name`: EKS cluster name
- `cluster_endpoint`: EKS API server endpoint
- `vpc_id`: EKS VPC ID
- `node_role_arn`: IAM role ARN for nodes
- `vpc_peering_connection_id`: Peering connection ID
- `configure_kubectl`: Command to configure kubectl

## Managing Environments

### Switch Between Environments

```bash
# List workspaces
terraform workspace list

# Switch to staging
terraform workspace select staging

# Switch to production
terraform workspace select production
```

### View Current Workspace

```bash
terraform workspace show
```

## Updating the Cluster

### Update Node Count

Edit `terraform.tfvars` and update the node group configuration, then:

```bash
terraform plan
terraform apply
```

### Update Kubernetes Version

Update `cluster_version` in `terraform.tfvars`:

```hcl
cluster_version = "1.29"
```

Then apply:

```bash
terraform plan
terraform apply
```

**Note**: Always test version upgrades in staging first.

## Clean Up

To destroy resources:

```bash
# Make sure you're in the correct workspace
terraform workspace select staging

# Destroy
terraform destroy
```

## Troubleshooting

### Nodes Not Joining Cluster

1. Check node IAM role has correct policies
2. Verify security group rules allow node-to-control-plane communication
3. Check CloudWatch logs for the cluster

### Cannot Pull ECR Images

1. Verify node IAM role has ECR permissions
2. Check if ECR repository is in the same region
3. Verify ECR repository policies

### Cannot Connect to RDS

1. Verify VPC peering connection is active
2. Check route tables have peering routes
3. Verify RDS security group allows ingress from EKS node security group
4. Test with a debug pod in the cluster

### State Lock Issues

If you get a state lock error:

```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

## Security Best Practices

1. **Private Subnets**: EKS nodes run in private subnets
2. **Encryption**: Enable encryption for EKS secrets
3. **RBAC**: Configure Kubernetes RBAC for access control
4. **Network Policies**: Implement network policies for pod-to-pod communication
5. **Secrets Management**: Use AWS Secrets Manager or Parameter Store
6. **Logging**: Enable CloudWatch Container Insights

## Cost Optimization

1. Use Spot Instances for non-production workloads
2. Right-size node instances based on workload
3. Enable cluster autoscaler
4. Use pod autoscaling (HPA/VPA)
5. Delete unused resources

## Additional Resources

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review security group rules
3. Verify IAM permissions
4. Check Terraform state