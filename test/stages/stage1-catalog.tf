module "catalog" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs"

  entitlement_key = var.cp_entitlement_key
  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  
}
