variable "kubeconfig_path" {
  description = "The path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "keycloak_namespace" {
  description = "Kubernetes namespace for Keycloak"
  type        = string
  default     = "keycloak"
}

variable "jenkins_namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "keycloak_helm_chart_version" {
  description = "Version of the Keycloak Helm chart to install"
  type        = string
  default     = "15.1.0"
}

variable "jenkins_helm_chart_version" {
  description = "Version of the Jenkins Helm chart to install"
  type        = string
  default     = "4.6.0"
} 