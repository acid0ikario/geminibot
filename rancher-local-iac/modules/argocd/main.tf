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

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.52.0"

  values = [
    <<-EOF
    server:
      extraArgs:
        - --insecure
      ingress:
        enabled: true
        ingressClassName: nginx
        hostname: ${var.argocd_hostname}
    
    repoServer:
      env:
        - name: SOPS_AGE_KEY_FILE
          value: /home/argocd/.config/sops/age/keys.txt
      
      # Init container para descargar SOPS
      extraContainers:
        - name: sops-bin
          image: alpine:latest
          command: ["/bin/sh", "-c"]
          args:
            - wget -O /sopsbin/sops https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 && chmod +x /sopsbin/sops && sleep 3600
          volumeMounts:
            - name: sops-bin
              mountPath: /sopsbin

      volumes:
        - name: sops-bin
          emptyDir: {}
        - name: sops-age-key
          secret:
            secretName: sops-age-key

      volumeMounts:
        - name: sops-bin
          mountPath: /usr/local/bin/sops
          subPath: sops
        - name: sops-age-key
          mountPath: /home/argocd/.config/sops/age/
    EOF
  ]
}

resource "kubernetes_secret" "sops_age_key" {
  metadata {
    name      = "sops-age-key"
    namespace = "argocd"
  }

  data = {
    "keys.txt" = base64encode(var.sops_age_secret_key)
  }
}

resource "kubernetes_secret" "argocd_repo_creds" {
  metadata {
    name      = "github-workloads-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = base64encode("git")
    url      = base64encode(var.workloads_repo_url)
    password = base64encode(var.github_token)
    username = base64encode("git")
  }

  depends_on = [helm_release.argocd]
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
          targetRevision: main
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
