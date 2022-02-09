module "mas_appsuite" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlementkey = module.catalog.entitlement_key
  cluster_ingress = "toolkit-dev-ocp48-gitops-2ab66b053c14936810608de9a1deac9c-0000.us-east.containers.appdomain.cloud"
  catalog_name = module.catalog.catalog_ibmoperators
  versionid = "8.x"
  instanceid = "mas86"
  certmgr_namespace = "cert-manager"

}
