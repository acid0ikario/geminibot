output "kubeconfig_command" {
  description = "Comando para configurar kubectl y conectarse al clúster local"
  value       = "kind get kubeconfig --name ${module.cluster.cluster_name} > ~/.kube/config"
}