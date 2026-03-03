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
  default     = "admin12345"
}