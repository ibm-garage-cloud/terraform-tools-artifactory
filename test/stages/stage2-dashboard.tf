module "dev_tools_dashboard" {
  source = "github.com/ibm-garage-cloud/terraform-tools-dashboard"

  cluster_ingress_hostname = module.dev_cluster.ingress_hostname
  cluster_config_file      = module.dev_cluster.config_file_path
  cluster_type             = module.dev_cluster.type_code
  tls_secret_name          = module.dev_cluster.tls_secret_name
  releases_namespace       = module.dev_capture_state.namespace
}
