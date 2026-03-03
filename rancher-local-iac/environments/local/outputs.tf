output "rancher_url" {
  description = "URL para acceder a la interfaz de Rancher"
  value       = "https://${var.rancher_hostname}"
}

output "rancher_password" {
  description = "Contraseña inicial de admin"
  value       = var.rancher_password
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Comando para configurar kubectl y conectarse al clúster local"
  value       = "kind get kubeconfig --name ${module.cluster.cluster_name} > ~/.kube/config"
}