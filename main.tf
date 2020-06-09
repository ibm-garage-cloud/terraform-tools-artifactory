provider "helm" {
  version = ">= 1.1.1"
  kubernetes {
    config_path = var.cluster_config_file
  }
}

locals {
  tmp_dir                = "${path.cwd}/.tmp"
  ingress_host           = "artifactory-${var.releases_namespace}.${var.cluster_ingress_hostname}"
  ingress_url            = "https://${local.ingress_host}"
  values_file            = "${path.module}/artifactory-values.yaml"
  config_name            = "artifactory-config"
  secret_name            = "artifactory-access"
}

resource "helm_release" "artifactory" {
  name         = "artifactory"
  repository   = "https://charts.jfrog.io/"
  chart        = "artifactory"
  version      = var.chart_version
  namespace    = var.releases_namespace
  timeout      = 1200
  force_update = true

  values = [
    file(local.values_file)
  ]

  set {
    name  = "ingress.enabled"
    value = var.cluster_type == "kubernetes" ? "true" : "false"
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = var.tls_secret_name
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.ingress_host
  }

  set {
    name  = "ingress.defaultBackend.enabled"
    value = "false"
  }

  set {
    name  = "ingress.hosts[0]"
    value = local.ingress_host
  }

  set {
    name  = "global.storageClass"
    value = var.storage_class != "" ? var.storage_class : "-"
  }

  set {
    name  = "artifactory.persistence.enabled"
    value = var.persistence
  }

  set {
    name  = "artifactory.persistence.storageClass"
    value = var.storage_class != "" ? var.storage_class : "-"
  }
}

resource "null_resource" "create-route" {
  depends_on = [helm_release.artifactory]
  count      = var.cluster_type != "kubernetes" ? 1 : 0

  triggers = {
    kubeconfig = var.cluster_config_file
    namespace  = var.releases_namespace
    name       = "artifactory"
    tmp_dir    = local.tmp_dir
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-artifactory-route.sh ${self.triggers.namespace} ${self.triggers.name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
      TMP_DIR    = self.triggers.tmp_dir
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -n ${self.triggers.namespace} route/${self.triggers.name} || exit 0"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
      TMP_DIR    = self.triggers.tmp_dir
    }
  }
}

resource "null_resource" "delete-consolelink" {
  count = var.cluster_type != "kubernetes" ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl delete consolelink -l grouping=garage-cloud-native-toolkit -l app=artifactory || exit 0"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource "helm_release" "artifactory-config" {
  depends_on = [helm_release.artifactory, null_resource.create-route, null_resource.delete-consolelink]

  name         = "artifactory-config"
  repository   = "https://ibm-garage-cloud.github.io/toolkit-charts/"
  chart        = "tool-config"
  namespace    = var.releases_namespace
  force_update = true

  set {
    name  = "name"
    value = "Artifactory"
  }

  set {
    name  = "url"
    value = local.ingress_url
  }

  set {
    name  = "username"
    value = "admin"
  }

  set {
    name  = "password"
    value = "password"
  }

  set {
    name  = "otherSecret.ENCRYPT_PASSWORD"
    value = ""
  }

  set {
    name  = "otherSecret.ADMIN_USER"
    value = "admin-access"
  }

  set {
    name  = "otherSecret.ADMIN_ACCESS_PASSWORD"
    value = "admin"
  }

  set {
    name  = "applicationMenu"
    value = var.cluster_type == "ocp4"
  }

  set {
    name  = "ingressSubdomain"
    value = var.cluster_ingress_hostname
  }
}
