
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo '$${OUTPUT}' > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.mas_appsuite.name
        branch      = module.mas_appsuite.branch
        namespace   = module.mas_appsuite.namespace
        server_name = module.mas_appsuite.server_name
        layer       = module.mas_appsuite.layer
        layer_dir   = module.mas_appsuite.layer == "infrastructure" ? "1-infrastructure" : (module.mas_appsuite.layer == "services" ? "2-services" : "3-applications")
        type        = module.mas_appsuite.type
      })
    }
  }
}
