variable "rancher_hostname" {
  description = "Hostname para el servidor Rancher."
  type        = string
}

variable "rancher_password" {
  description = "Contraseña inicial (bootstrap) para el usuario admin de Rancher"
  type        = string
}