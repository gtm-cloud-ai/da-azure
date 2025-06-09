# GCP GKE Clusters for Keycloak and Jenkins

This Terraform configuration sets up two Google Kubernetes Engine (GKE) clusters:
1. A Keycloak cluster for identity and access management
2. A Jenkins cluster for CI/CD

## Prerequisites

- Google Cloud SDK installed and configured
- Terraform >= 1.0.0
- kubectl
- helm

## Architecture

- VPC network with custom subnet
- Secondary IP ranges for pods and services
- Regional GKE clusters
- Dedicated service account for node pools
- e2-standard-2 nodes for both clusters

## Installation

1. Configure Google Cloud SDK:
```bash
gcloud auth application-default login
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
- Node type: e2-standard-2
- Node count: 2
- VPC-native networking
- Regular release channel

### Jenkins Cluster
- Cluster name: jenkins-cluster
- Node type: e2-standard-2
- Node count: 2
- VPC-native networking
- Regular release channel

## Configuration

Customize the configuration by creating a `terraform.tfvars` file:

```hcl
project_id = "your-project-id"
region = "us-central1"
prefix = "k8s"
environment = "production"
subnet_cidr = "10.0.0.0/20"
pods_cidr = "10.1.0.0/16"
services_cidr = "10.2.0.0/20"
```

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Security Notes

- VPC-native networking enabled
- Dedicated service account for nodes
- Regular release channel for automatic updates
- Cloud IAM integration
- Private nodes configuration available 