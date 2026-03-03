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