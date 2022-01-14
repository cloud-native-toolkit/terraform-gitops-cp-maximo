#  Maximo Gitops terraform module
![Verify and release module](https://github.com/cloud-native-toolkit/terraform-gitops-cp-maximo/workflows/Verify%20and%20release%20module/badge.svg)

Deploys Maximo Application Suite via gitops - UNDER DEVELOPMENT
```
## Supported platforms

- OCP 4.6+

## Module dependencies

The module uses the following elements

### Environment

- kubectl - used to apply the yaml to create the route

## Suggested companion modules

The module itself requires some information from the cluster and needs a
namespace to be created. The following companion
modules can help provide the required information:

- Gitops - github.com/cloud-native-toolkit/terraform-tools-gitops
- Namespace - github.com/ibm-garage-cloud/terraform-cluster-namespace
- StorageClass - github.com/cloud-native-toolkit/terraform-gitops-ocp-storageclass


## Example usage

```hcl-terraform
module "maximo" {

}
```