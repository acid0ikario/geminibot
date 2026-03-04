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
  version    = "1.24.2" # Versión estable recomendada
  
  # Ensure CRDs are established before moving on
  wait = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = "1.24.2"

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

resource "helm_release" "kiali_server" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = "2.22.0"

  values = [
    <<-EOF
    auth:
      strategy: anonymous
    external_services:
      prometheus:
        url: "http://prometheus.istio-system.svc.cluster.local:9090"
    server:
      port: 20001
      web_root: /kiali
    ingress:
      enabled: true
      ingressClassName: nginx
      hosts:
        - kiali.127.0.0.1.nip.io
    EOF
  ]

  depends_on = [helm_release.istiod]
}
