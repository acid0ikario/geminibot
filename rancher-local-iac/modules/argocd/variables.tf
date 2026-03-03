variable "argocd_hostname" {
  description = "Hostname para acceder a ArgoCD"
  type        = string
  default     = "argocd.127.0.0.1.nip.io"
}

variable "workloads_repo_url" {
  description = "URL del repositorio de workloads para ArgoCD"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token para autenticación de ArgoCD"
  type        = string
  sensitive   = true
}

variable "sops_age_secret_key" {
  description = "Clave privada de Age para desencriptar secretos con SOPS"
  type        = string
  sensitive   = true
}
