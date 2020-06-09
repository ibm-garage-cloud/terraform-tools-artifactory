module "dev_serviceaccount_artifactory" {
  source = "github.com/ibm-garage-cloud/terraform-cluster-serviceaccount.git?ref=v1.2.0"

  cluster_type             = module.dev_cluster.type_code
  namespace                = module.dev_capture_state.namespace
  cluster_config_file_path = module.dev_cluster.config_file_path
  service_account_name     = "artifactory-artifactory"
  sscs                     = ["anyuid", "privileged"]
}

module "dev_tools_artifactory" {
  source = "github.com/ibm-garage-cloud/terraform-tools-artifactory.git"

  cluster_type             = module.dev_cluster.type_code
  service_account          = module.dev_serviceaccount_artifactory.name
  releases_namespace       = module.dev_serviceaccount_artifactory.namespace
  cluster_ingress_hostname = module.dev_cluster.ingress_hostname
  cluster_config_file      = module.dev_cluster.config_file_path
  tls_secret_name          = module.dev_cluster.tls_secret_name
  persistence              = false
}
