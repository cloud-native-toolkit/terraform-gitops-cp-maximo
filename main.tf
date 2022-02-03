locals {
  name          = "ibmmax"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"

  layer = "services"
  application_branch = "main"
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

// patch SBO to v0.8.0 level-manual approval
module "service_account" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = "openshift-operators"
  name = "installplan-approver-job"
  rbac_rules = [{
    apiGroups = ["operators.coreos.com"]
    resources = ["installplans","subscriptions"]
    verbs = ["get","list","patch"]
  }]
  sccs = ["anyuid"]
  server_name = var.server_name
  rbac_cluster_scope = false
}

resource null_resource patch_sbo {
  provisioner "local-exec" {
    command = "${path.module}/scripts/patchSBO.sh '${local.yaml_dir}' "
    
    environment = {
      BIN_DIR = local.bin_dir
    }
  }
} 

// Add entitlement secret Need to Add secret name ibm-entitlement

module "gitops_module" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  docker_server = "cp.icr.io"
  docker_username = "cp"
  docker_password = var.entitlementkey
}

# Update MAS Core CRD






# Deploy truststore manager
# Deploy needed common services
# Install IBM Maximo Application Suite operator
# Install IBM Maximo Application Suite core systems


/* don't run yet

resource null_resource setup_gitops {
  depends_on = [null_resource.patch_sbo]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}  */
