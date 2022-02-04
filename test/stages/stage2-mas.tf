module "mas_appsuite" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlementkey = var.cp_entitlement_key
  cluster_ingress = module.dev_cluster.platform.ingress
  versionid = "8.5.x"
  instanceid = "mas85"
  
}
