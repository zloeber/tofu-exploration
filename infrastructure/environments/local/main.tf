locals {
  ## in the future, we can read the config files and secrets from a central location
  # global_config         = jsondecode(file("${path.module}/../../../config/global.json"))
  # env_config            = jsondecode(file("${path.module}/../../../config/env.${var.env}.json"))
  # secret_config         = jsondecode(file("${path.module}/../../../secrets/${var.env}.json"))
  # kube_config_base_path = "${path.module}/../../../secrets/${var.env}/kube"
  # config                = merge(local.global_config, local.env_config)
  # kube_clusters         = local.config.kube_clusters
  # kube_map              = { for cluster in local.kube_clusters : cluster.name => cluster }
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.7.0"
    }
  }
  backend "local" {
    path = "../../../secrets/local/infrastructure_tfstate.json"
  }
}


## Kind
module "clusters" {
  for_each = toset(var.clusters)
  source              = "../../modules/k8s-kind-cluster"
  cluster_name        = each.key
  cluster_config_path = "../../../secrets/${var.env}/${each.key}_config"
}
