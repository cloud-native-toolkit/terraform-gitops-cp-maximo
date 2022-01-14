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



resource null_resource patch_sbo {
  provisioner "local-exec" {
    command = "${path.module}/scripts/patchSBO.sh '${local.yaml_dir}' "
    
    environment = {
      BIN_DIR = local.bin_dir
    }
  }
} 

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
