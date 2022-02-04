
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo '$${OUTPUT}' > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.gitops.name
        branch      = module.gitops.branch
        namespace   = module.gitops.namespace
        server_name = module.gitops.server_name
        layer       = module.gitops.layer
        layer_dir   = module.gitops.layer == "infrastructure" ? "1-infrastructure" : (module.gitops.layer == "services" ? "2-services" : "3-applications")
        type        = module.gitops.type
      })
    }
  }
}
