variable "argocd_hostname" {
  description = "Hostname para acceder a ArgoCD"
  type        = string
  default     = "argocd.127.0.0.1.nip.io"
}

variable "workloads_repo_url" {
  description = "URL del repositorio de workloads para ArgoCD"
  type        = string
}
