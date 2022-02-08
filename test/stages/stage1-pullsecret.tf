module "pullsecret" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  
  namespace = module.gitops_namespace.name
  docker_server = "cp.icr.io"
  docker_username = "cp"
  docker_password = module.catalog.entitlement_key
  secret_name = "ibm-entitlement"

}
