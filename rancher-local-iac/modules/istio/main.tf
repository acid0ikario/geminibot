terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = "1.21.0" # Versión estable recomendada
  
  # Ensure CRDs are established before moving on
  wait = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = "1.21.0"

  values = [
    <<-EOF
    global:
      proxy:
        resources:
          requests:
            cpu: 10m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
    pilot:
      resources:
        requests:
          cpu: 10m
          memory: 256Mi
        limits:
          cpu: 500m
          memory: 1024Mi
    EOF
  ]

  depends_on = [helm_release.istio_base]
}
