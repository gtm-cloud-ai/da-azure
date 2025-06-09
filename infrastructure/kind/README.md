# Kind Clusters for Keycloak and Jenkins

This Terraform configuration sets up two Kind (Kubernetes in Docker) clusters:
1. A Keycloak cluster for identity and access management
2. A Jenkins cluster for CI/CD

## Prerequisites

- Docker installed and running
- Terraform >= 1.0.0
- kubectl
- helm

## Installation

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Cluster Details

### Keycloak Cluster
- Cluster name: keycloak-cluster
- Ingress ports:
  - HTTP: 8080
  - HTTPS: 8443
- Components:
  - 1 control-plane node
  - 1 worker node

### Jenkins Cluster
- Cluster name: jenkins-cluster
- Ingress ports:
  - HTTP: 9080
  - HTTPS: 9443
- Components:
  - 1 control-plane node
  - 1 worker node

## Accessing the Services

### Keycloak
- URL: https://localhost:8443
- Default namespace: keycloak

### Jenkins
- URL: https://localhost:9443
- Default namespace: jenkins

## Clean Up

To destroy the clusters and clean up all resources:
```bash
terraform destroy
```

## Configuration

You can customize the configuration by modifying the following variables in a `terraform.tfvars` file:

```hcl
kubeconfig_path = "~/.kube/config"
keycloak_namespace = "keycloak"
jenkins_namespace = "jenkins"
keycloak_helm_chart_version = "15.1.0"
jenkins_helm_chart_version = "4.6.0"
``` 