terraform {
    required_providers {
        kind = {
            source  = "tehcyx/kind"
            version = "~> 0.2.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.20"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.9"
        }
    }
}

provider "kind" {}

provider "kubernetes" {
    config_path = pathexpand(kind_cluster.default.kubeconfig_path)
}

provider "helm" {
    kubernetes {
        config_path = pathexpand(kind_cluster.default.kubeconfig_path)
    }
}

resource "kind_cluster" "default" {
    name            = "local-k8s"
    wait_for_ready  = true
    node_image      = "kindest/node:v1.26.3"

    kind_config {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
            role = "control-plane"
            extra_port_mappings {
                container_port = 30080
                host_port     = 8080  # Jenkins port
            }
            extra_port_mappings {
                container_port = 30081
                host_port     = 8081  # Keycloak port
            }
            extra_port_mappings {
                container_port = 30433
                host_port     = 1433  # SQL Server port
            }
        }

        node {
            role = "worker"
        }
    }
}

resource "kubernetes_namespace" "keycloak" {
    metadata {
        name = "keycloak"
    }
    depends_on = [kind_cluster.default]
}

resource "kubernetes_namespace" "jenkins" {
    metadata {
        name = "jenkins"
    }
    depends_on = [kind_cluster.default]
}

resource "kubernetes_namespace" "saas-platform" {
    metadata {
        name = "saas-platform"
    }
    depends_on = [kind_cluster.default]
}

resource "helm_release" "keycloak" {
    name       = "keycloak"
    repository = "https://charts.bitnami.com/bitnami"
    chart      = "keycloak"
    version    = "15.1.1"
    namespace  = kubernetes_namespace.keycloak.metadata[0].name

    values = [
        <<-EOT
        service:
          type: NodePort
          nodePorts:
            http: 30081
        ingress:
          enabled: false
        EOT
    ]

    set {
        name  = "auth.adminUser"
        value = "admin"
    }

    set {
        name  = "auth.adminPassword"
        value = "admin123" # Change this in production
    }

    depends_on = [kubernetes_namespace.keycloak]
}

resource "helm_release" "jenkins" {
    name       = "jenkins"
    repository = "https://charts.jenkins.io"
    chart      = "jenkins"
    namespace  = kubernetes_namespace.jenkins.metadata[0].name

    values = [
        <<-EOT
        controller:
          serviceType: NodePort
          nodePort: 30080
        EOT
    ]

    set {
        name  = "controller.admin.username"
        value = "admin"
    }

    set {
        name  = "controller.admin.password"
        value = "admin123" # Change this in production
    }

    depends_on = [kubernetes_namespace.jenkins]
}

resource "null_resource" "keycloak_post_install" {
    depends_on = [helm_release.keycloak]

    provisioner "local-exec" {
        command = <<-EOT
            # Wait for Keycloak to be ready
            echo "Waiting for Keycloak to be ready..."
            sleep 30

            # Convert Excel to JSON
            #python3 ../scripts/convert_users.py ../data/test_users.xlsx

            # Import users
            #../scripts/import_users.sh
        EOT
    }
}

resource "kubernetes_deployment" "sqlserver" {
  metadata {
    name      = "sqlserver"
    namespace = kubernetes_namespace.saas-platform.metadata[0].name
    labels = {
      app = "sqlserver"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sqlserver"
      }
    }

    template {
      metadata {
        labels = {
          app = "sqlserver"
        }
      }

      spec {
        container {
          image = "fthornton67/gtm-cloud-saas-db:latest"
          name  = "sqlserver"

          env {
            name  = "ACCEPT_EULA"
            value = "Y"
          }

          env {
            name  = "MSSQL_SA_PASSWORD"
            value = "mssql_2025"
          }

          port {
            container_port = 1433
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.saas-platform]
}

resource "kubernetes_service" "sqlserver" {
    metadata {
        name      = "sqlserver"
        namespace = kubernetes_namespace.saas-platform.metadata[0].name
    }

    spec {
        type = "NodePort"
        port {
            port        = 1433
            target_port = 1433
            node_port   = 30433  # This must match the container_port in kind_cluster config
        }

        selector = {
            app = "sqlserver"
        }
    }

    depends_on = [kubernetes_deployment.sqlserver]
}

/*
# PersistentVolumeClaim (PVC) for SQL Server data storage
# - Requests 10GB of storage space
# - Uses ReadWriteOnce access mode (can be mounted as read-write by a single node)
# - Links to standard storage class
# - Matches labels with sqlserver deployment
# - Depends on saas-platform namespace creation
resource "kubernetes_persistent_volume_claim" "sqlserver" {
  metadata {
    name      = "sqlserver-data"
    namespace = kubernetes_namespace.saas-platform.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "standard"
    volume_name = "sqlserver-data"
    selector {
      match_labels = {
        app = "sqlserver"
      }
    }
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }

  depends_on = [kubernetes_namespace.saas-platform]
}
*/