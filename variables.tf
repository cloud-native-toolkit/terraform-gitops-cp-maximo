
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "entitlementkey" {
  type        = string
  description = "IBM entitlement key for MAS"
}

variable "cluster_ingress" {
  type        = string
  description = "Ingress for cluster"
}

variable "instanceid" {
  type        = string
  description = "instance ID for MAS - for example: masdemo or mas8 "
  default     = "mas8"
}

variable "versionid" {
  type        = string
  description = "version for MAS - this must match the update channel: 8.x for latest, or 8.5.x / 8.6.x etc."
  default     = "8.x"
}

variable "catalog_name" {
  type        = string
  description = "Name of the IBM Operator OpenShift Catalog that contains MAS"
}

variable "certmgr_namespace" {
  type        = string
  description = "Namespace of the cert-manager"
  default     = "cert-manager"
}
