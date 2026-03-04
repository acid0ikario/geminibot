terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}

# NGINX Ingress
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.9.1"

  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }
  set {
    name  = "controller.hostNetwork"
    value = "false"
  }
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "true"
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  # Configurar logs en formato JSON para que Loki los parsee fácilmente
  values = [
    <<-EOF
    controller:
      config:
        log-format-upstream: '{"log_type":"ingress_access","time":"$time_iso8601","remote_addr":"$proxy_protocol_addr","x-forward-for":"$proxy_add_x_forwarded_for","request_id":"$req_id","remote_user":"$remote_user","bytes_sent":"$bytes_sent","request_time":"$request_time","status":"$status","vhost":"$host","request_proto":"$server_protocol","path":"$uri","request_query":"$args","request_length":"$request_length","duration":"$request_time","method":"$request_method","http_referrer":"$http_referer","http_user_agent":"$http_user_agent"}'
      extraArgs:
        profiling: "false"
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
    EOF
  ]
}

# Cert-Manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.2"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Rancher Server
resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "bootstrapPassword"
    value = var.rancher_password
  }

  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx
  ]
}
