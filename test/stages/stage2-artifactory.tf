module "dev_tools_artifactory" {
  source = "github.com/ibm-garage-cloud/terraform-tools-artifactory.git"

  cluster_type             = module.dev_cluster.type_code
  service_account          = "artifactory-artifactory"
  releases_namespace       = module.dev_capture_state.namespace
  cluster_ingress_hostname = module.dev_cluster.ingress_hostname
  cluster_config_file      = module.dev_cluster.config_file_path
  tls_secret_name          = module.dev_cluster.tls_secret_name
  persistence              = false
}
