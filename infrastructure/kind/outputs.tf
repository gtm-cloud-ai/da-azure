output "keycloak_cluster_name" {
  description = "Name of the Keycloak Kind cluster"
  value       = kind_cluster.keycloak.name
}

output "jenkins_cluster_name" {
  description = "Name of the Jenkins Kind cluster"
  value       = kind_cluster.jenkins.name
}

output "keycloak_kubeconfig" {
  description = "Kubeconfig for the Keycloak cluster"
  value       = kind_cluster.keycloak.kubeconfig
  sensitive   = true
}

output "jenkins_kubeconfig" {
  description = "Kubeconfig for the Jenkins cluster"
  value       = kind_cluster.jenkins.kubeconfig
  sensitive   = true
}

output "keycloak_endpoint" {
  description = "Endpoint for accessing Keycloak"
  value       = "https://localhost:8443"
}

output "jenkins_endpoint" {
  description = "Endpoint for accessing Jenkins"
  value       = "https://localhost:9443"
} 