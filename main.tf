locals {
  name           = "ibm-masapp-suite"
  operator_name  = "ibm-masapp-suite-operator"
  bin_dir        = module.setup_clis.bin_dir
  tmp_dir        = "${path.cwd}/.tmp/${local.name}"
  yaml_dir       = "${local.tmp_dir}/chart/${local.name}"
  operator_yaml_dir = "${local.tmp_dir}/chart/${local.operator_name}"

  layer              = "services"
  type               = "instances"
  operator_type      = "operators"
  application_branch = "main"

  core-namespace     = "mas-${var.instanceid}-core"
  admin_link         = "https://admin.${var.cluster_ingress}/"
  layer_config       = var.gitops_config[local.layer]
  installPlan        = var.installPlan
 
# set values content for subscription
  values_content = {
        massuite = {
          instanceid = var.instanceid
          certmgr = var.certmgr_namespace
          core-namespace = local.core-namespace
          cluster_ingress = var.cluster_ingress
          admin_link = local.admin_link
        }
        workspace = {
          name = local.workspace_name
          dbschema = var.db_schema
        }
    }
  values_content_operator = {
        subscription = {
          channel = var.versionid
          installPlanApproval = local.installPlan
          source = var.catalog_name
          sourceNamespace = var.catalog_namespace
        }
    }

} 

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

# Create the namespace and pullsecret needed for MAS

module masNamespace {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  name = "${local.core-namespace}"
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

# Add values for operator chart
resource "null_resource" "deployOperator" {

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-operator-yaml.sh '${local.operator_name}' '${local.operator_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content_operator)
    }
  }
}


# Add values for instance charts
resource "null_resource" "deployInstance" {

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}


# Deploy Operator
resource gitops_module masapp_operator {
  depends_on = [null_resource.deployOperator]

  name        = local.operator_name
  namespace   = local.core-namespace
  content_dir = local.operator_yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.operator_type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

# Deploy Instance
resource gitops_module masapp {
  depends_on = [gitops_module.masapp_operator]

  name        = local.name
  namespace   = local.core-namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
