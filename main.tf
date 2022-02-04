locals {
  name          = "ibmmax"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"

  layer = "services"
  application_branch = "main"
  type  = "base"
  namespace = var.namespace
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
  depends_on = [module.service_account]

  provisioner "local-exec" {
    command = "${path.module}/scripts/patchSBO.sh '${local.yaml_dir}' "
    
    environment = {
      BIN_DIR = local.bin_dir
    }
  }
} 

// Add entitlement secret Need to Add secret name ibm-entitlement
module "add_entitlement" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  namespace = var.namespace
  kubeseal_cert = var.kubeseal_cert
  docker_server = "cp.icr.io"
  docker_username = "cp"
  docker_password = var.entitlementkey
  secret_name = "ibm-entitlement"
}

/*
# Update MAS Core CRD

resource null_resource update_coreCRD {
  provisioner "local-exec" {
    command = "${path.module}/scripts/updateCRD.sh '${local.yaml_dir}' ${var.cluster_ingress} ${var.cluster_ingress}"
    
    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}  */


# Deploy truststore manager

// insert call to TM gitops module

# Deploy needed common services

// may be done via cp4d work- check on this otherwise insert call to ibm-cs module 

# Install IBM Maximo Application Suite operator

resource "null_resource" "deployMASop" {
  depends_on = [module.add_entitlement]

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployMASop.sh '${local.yaml_dir}' ${var.versionid} '${var.namespace}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }

}

# Install IBM Maximo Application Suite core systems

resource null_resource setup_gitops {
  depends_on = [null_resource.patch_sbo,null_resource.deployMASop]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}  

