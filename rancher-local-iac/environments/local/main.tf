module "cluster" {
  source       = "../../modules/cluster"
  cluster_name = var.cluster_name
}

module "rancher_stack" {
  source           = "../../modules/rancher_stack"
  rancher_hostname = var.rancher_hostname
  rancher_password = var.rancher_password

  depends_on = [module.cluster]
}

module "argocd" {
  source              = "../../modules/argocd"
  argocd_hostname     = var.argocd_hostname
  workloads_repo_url  = var.workloads_repo_url
  github_token        = var.github_token
  sops_age_secret_key = var.sops_age_secret_key

  depends_on = [module.cluster, module.rancher_stack]
}