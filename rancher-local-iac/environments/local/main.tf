module "cluster" {
  source       = "../../modules/cluster"
  cluster_name = var.cluster_name
}

module "argocd" {
  source              = "../../modules/argocd"
  argocd_hostname     = var.argocd_hostname
  workloads_repo_url  = var.workloads_repo_url
  github_token        = var.github_token
  sops_age_secret_key = var.sops_age_secret_key

  depends_on = [module.cluster]
}