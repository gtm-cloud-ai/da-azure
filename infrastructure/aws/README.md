# AWS EKS Clusters for Keycloak and Jenkins

This Terraform configuration sets up two Amazon EKS (Elastic Kubernetes Service) clusters:
1. A Keycloak cluster for identity and access management
2. A Jenkins cluster for CI/CD

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm

## Architecture

- VPC with public and private subnets across 2 availability zones
- NAT Gateway for private subnet internet access
- EKS clusters in private subnets
- Managed node groups with t3.medium instances

## Installation

1. Configure AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Cluster Details

### Keycloak Cluster
- Cluster name: keycloak-cluster
- Node type: t3.medium
- Node count: 2 (min: 1, max: 3)
- Auto-scaling enabled
- Private networking

### Jenkins Cluster
- Cluster name: jenkins-cluster
- Node type: t3.medium
- Node count: 2 (min: 1, max: 3)
- Auto-scaling enabled
- Private networking

## Configuration

Customize the configuration by creating a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
environment = "production"
vpc_cidr = "10.0.0.0/16"
kubernetes_version = "1.27"
```

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Security Notes

- Clusters are deployed in private subnets
- Control plane logging is enabled
- Node groups use IMDSv2
- Security groups are configured with minimal required access 