module "mas_appsuite" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlementkey = module.catalog.entitlement_key
  cluster_ingress = module.dev_cluster.platform.ingress

  catalog_name = module.catalog.catalog_ibmoperators
  certmgr_namespace = module.certmgr.namespace
  versionid = "8.x"
  instanceid = "mas8"

}
