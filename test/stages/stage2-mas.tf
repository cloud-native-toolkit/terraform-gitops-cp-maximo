module "gitops_module" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name

  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlement_key = module.catalog.entitlement_key
  cluster_ingress = module.dev_cluster.platform.ingress

  catalog_name = module.catalog.catalog_ibmoperators
  instanceid = "mas8"
}

resource null_resource write_namespace {
  depends_on = [module.gitops_module]
  
  provisioner "local-exec" {
    command = "echo -n 'mas-mas8-core' > .namespace"
  }
}
