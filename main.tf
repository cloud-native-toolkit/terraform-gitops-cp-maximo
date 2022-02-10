locals {
  name          = "maximo"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  inst_dir      = "${local.yaml_dir}/instance"

  layer = "services"
  application_branch = "main"
  type  = "base"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}


# Install IBM Maximo Application Suite operator

resource "null_resource" "deployMASop" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deployMASop.sh '${local.yaml_dir}' ${var.versionid} '${var.namespace}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

# Install IBM Maximo Application Suite core systems

resource "null_resource" "deployMASSuite" {
  depends_on = [null_resource.setup_gitops_op]

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployMASSuite.sh '${local.yaml_dir}' ${var.instanceid} '${var.namespace}' '${var.cluster_ingress}' '${var.certmgr_namespace}' "

    environment = {
      BIN_DIR = local.bin_dir
    }
  }

}

resource null_resource setup_gitops_op {
  depends_on = [null_resource.deployMASop,null_resource.deployMASSuite]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}  


/*
resource null_resource setup_gitops_suite {
  depends_on = [null_resource.deployMASSuite]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module 'maximosuite' -n '${var.namespace}' --contentDir '${local.inst_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
} */
