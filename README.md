
## Usage

### 1. Deploy CloudFormation Stacks

```bash
# Deploy EKS IAM roles
aws cloudformation deploy --template-file cloudformation/eks-iam.yaml --stack-name eks-iam-stack --capabilities CAPABILITY_NAMED_IAM

# Deploy RDS in private network
aws cloudformation deploy --template-file cloudformation/rds-private.yaml --stack-name rds-private-stack --parameter-overrides DBPassword=<YOUR_DB_PASSWORD>
```

### 2. Initialize and Apply Terraform Configurations

```bash
cd terraform/eks

# Initialize Terraform
terraform init

# Create staging environment
terraform workspace select staging || terraform workspace new staging
terraform plan
terraform apply

# Create production environment
terraform workspace select production || terraform workspace new production
terraform plan
terraform apply
```

### 3. Build and Deploy the Mock Application

```bash
cd app

# Build Docker image
docker build -t mock-app .

# Create ECR repository (if not exists)
aws ecr create-repository --repository-name mock-app --region <REGION>

# Login to ECR
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com

# Tag and push image
docker tag mock-app:latest <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/mock-app:latest
docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/mock-app:latest

# Deploy to Kubernetes
cd ../k8s
# Update deployment.yaml with actual values
kubectl apply -f deployment.yaml
```

## Environments

- **Staging**: Use `terraform workspace select staging`
- **Production**: Use `terraform workspace select production`

Both environments have identical configurations but separate resources.

## Evaluation Criteria

- Infrastructure as Code best practices
- Security configurations (IAM, networking)
- Environment separation
- Containerization and deployment
- Private network connectivity
- Code organization and documentation
