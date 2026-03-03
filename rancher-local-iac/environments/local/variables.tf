variable "cluster_name" {
  description = "The name of the Kind cluster"
  type        = string
  default     = "rancher-local"
}

variable "rancher_hostname" {
  description = "Hostname para el servidor Rancher. Usamos nip.io para resolver a localhost."
  type        = string
  default     = "rancher.127.0.0.1.nip.io"
}

variable "rancher_password" {
  description = "Contraseña inicial (bootstrap) para el usuario admin de Rancher"
  type        = string
  sensitive   = true
}

variable "argocd_hostname" {
  description = "Hostname para acceder a ArgoCD"
  type        = string
  default     = "argocd.127.0.0.1.nip.io"
}

variable "workloads_repo_url" {
  description = "URL del repositorio de workloads para ArgoCD"
  type        = string
  default     = "https://github.com/acid0ikario/k8s-workloads.git"
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
