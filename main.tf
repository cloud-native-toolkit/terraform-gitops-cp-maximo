locals {
  name          = "maximo"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  inst_dir      = "${local.yaml_dir}/instance"

  layer = "services"
  application_branch = "main"
  type  = "base"
  namespace = "mas-${var.instanceid}-core"
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

# Create the namespace and pullsecret needed for MAS

module masNamespace {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  name = "${local.namespace}"
  create_operator_group = true
}

module "pullsecret" {
  depends_on = [module.masNamespace]

  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  
  namespace = module.masNamespace.name
  docker_server = "cp.icr.io"
  docker_username = "cp"
  docker_password = var.entitlement_key
  secret_name = "ibm-entitlement"
}


# Install IBM Maximo Application Suite operator

resource "null_resource" "deployMASop" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployMASop.sh '${local.yaml_dir}' ${var.versionid} '${local.namespace}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

# Install IBM Maximo Application Suite core system instance

resource "null_resource" "deployMASSuite" {
  depends_on = [null_resource.deployMASop]

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployMASSuite.sh '${local.inst_dir}' ${var.instanceid} '${local.namespace}' '${var.cluster_ingress}' '${var.certmgr_namespace}' "

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource setup_gitops_op {
  depends_on = [null_resource.deployMASop]

  triggers = {
    name = local.name
    namespace = local.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"
              
    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}  

resource null_resource setup_gitops_suite {
  depends_on = [null_resource.deployMASSuite,null_resource.setup_gitops_op]

  triggers = {
    name = "maximosuite"
    namespace = local.namespace
    inst_dir = local.inst_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.inst_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.inst_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
} 
