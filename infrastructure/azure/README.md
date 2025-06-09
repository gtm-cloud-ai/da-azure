# Azure AKS Clusters for Keycloak and Jenkins

This Terraform configuration sets up two Azure Kubernetes Service (AKS) clusters:
1. A Keycloak cluster for identity and access management
2. A Jenkins cluster for CI/CD

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.0.0
- kubectl
- helm

## Architecture

- Resource group for all resources
- Virtual Network with dedicated subnet
- AKS clusters with managed identities
- Standard_D2s_v3 nodes for both clusters

## Installation

1. Login to Azure:
```bash
az login
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
- Node type: Standard_D2s_v3
- Node count: 2
- System-assigned managed identity
- Azure CNI networking

### Jenkins Cluster
- Cluster name: jenkins-cluster
- Node type: Standard_D2s_v3
- Node count: 2
- System-assigned managed identity
- Azure CNI networking

## Configuration

Customize the configuration by creating a `terraform.tfvars` file:

```hcl
prefix = "k8s"
location = "eastus"
environment = "production"
kubernetes_version = "1.27"
vnet_cidr = "10.0.0.0/16"
aks_subnet_cidr = "10.0.1.0/24"
```

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Security Notes

- Clusters use managed identities
- Azure RBAC enabled
- Network policy enabled
- Azure Monitor integration available
- Standard load balancer SKU used 