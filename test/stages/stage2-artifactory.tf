module "dev_tools_artifactory" {
  source = "./module"

  cluster_type             = module.dev_cluster.type_code
  service_account          = "artifactory-artifactory"
  releases_namespace       = module.dev_capture_state.namespace
  cluster_ingress_hostname = module.dev_cluster.ingress_hostname
  cluster_config_file      = module.dev_cluster.config_file_path
  tls_secret_name          = module.dev_cluster.tls_secret_name
  image_url                = module.dev_tools_dashboard.base_icon_url
  persistence              = false
}
