module "dev_tools_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-namespace.git"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.namespace
  cluster_type             = module.dev_cluster.platform.type_code
}
