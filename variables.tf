
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

variable "entitlement_key" {
  type        = string
  description = "IBM entitlement key for MAS"
}

variable "cluster_ingress" {
  type        = string
  description = "Ingress for cluster"
}

variable "instanceid" {
  type        = string
  description = "instance name for to use for MAS Suite"
  default     = "masapps"
}

variable "versionid" {
  type        = string
  description = "version for MAS - this must match the update channel: 8.x for latest"
  default     = "8.7.x"
}

variable "installPlan" {
  type        = string
  description = "Install Plan for App"
  default     = "Automatic"
}

variable "catalog_name" {
  type        = string
  description = "App catalog source"
  default     = "ibm-operator-catalog"
}

variable "catalog_namespace" {
  type        = string
  description = "Catalog source namespace"
  default     = "openshift-marketplace"
}

variable "certmgr_namespace" {
  type        = string
  description = "Namespace of the cert-manager: should stay default value unless using another cert manager"
  default     = "ibm-common-services"
}

variable "issuer_name" {
  type        = string
  description = "Certificate Issuer name on the cluster to use if not using self signed certs"
  default     = ""
}

variable "issuer_duration" {
  type        = string
  description = "Certificate duration to use if not using self signed certs - Example: 8760h0m0s"
  default     = ""
}

variable "issuer_renewbefore" {
  type        = string
  description = "Certificate renew before definion to use if not using self signed certs - Example: 720h0m0s"
  default     = ""
}