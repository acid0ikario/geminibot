terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.52.0"

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.hostname"
    value = var.argocd_hostname
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
}

# App of Apps - Bootstrap para leer el repositorio de workloads
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  version    = "1.4.1"

  values = [
    <<-EOF
    applications:
      - name: root-workloads
        namespace: argocd
        project: default
        source:
          repoURL: ${var.workloads_repo_url}
          targetRevision: HEAD
          path: apps
        destination:
          server: https://kubernetes.default.svc
          namespace: argocd
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
          syncOptions:
            - CreateNamespace=true
    EOF
  ]

  depends_on = [helm_release.argocd]
}
