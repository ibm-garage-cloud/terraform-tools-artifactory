output "ingress_host" {
  description = "The ingress host for the Artifactory instance"
  value       = local.ingress_host
  depends_on  = [helm_release.artifactory]
}

output "ingress_url" {
  description = "The ingress url for the Artifactory instance"
  value       = local.ingress_url
  depends_on  = [helm_release.artifactory]
}

output "config_name" {
  description = "The name of the secret created to store the url"
  value       = local.config_name
  depends_on  = [helm_release.artifactory]
}

output "secret_name" {
  description = "The name of the secret created to store the credentials"
  value       = local.secret_name
  depends_on  = [helm_release.artifactory]
}
