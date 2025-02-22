terraform {
  required_version = ">= 1.0.0"
  required_providers {
    k3d = {
      source  = "pvotal-tech/k3d"
      version = "0.0.7"
    }
  }
}

locals {
  cluster_config = "${var.cluster_config_path}/${var.cluster_name}_config"
}

resource "k3d_cluster" "this" {
  name    = var.cluster_name
  servers = 1
  agents  = 2

  kube_api {
    host      = "localhost"
    host_ip   = "127.0.0.1"
    host_port = 6445
  }

  image = "rancher/k3s:v1.26.4-k3s1"
  # network = "my-custom-net"
  # token   = "superSecretToken"

  # volume {
  #   source      = "/my/host/path"
  #   destination = "/path/in/node"
  #   node_filters = [
  #     "server[0]",
  #     "agent[*]",
  #   ]
  # }

  port {
    host_port      = 8080
    container_port = 80
    node_filters = [
      "loadbalancer",
    ]
  }

  # label {
  #   key   = "foo"
  #   value = "bar"
  #   node_filters = [
  #     "agent[1]",
  #   ]
  # }

  # env {
  #   key   = "bar"
  #   value = "baz"
  #   node_filters = [
  #     "server[0]",
  #   ]
  # }

  #   registries {
  #     create = {
  #       name      = "my-registry"
  #       host      = "my-registry.local"
  #       image     = "docker.io/some/registry"
  #       host_port = "5001"
  #     }
  #     use = [
  #       "k3d-myotherregistry:5000"
  #     ]
  #     config = <<EOF
  # mirrors:
  #   "my.company.registry":
  #     endpoint:
  #       - http://my.company.registry:5000
  # EOF
  #   }

  k3d {
    disable_load_balancer = false
    disable_image_volume  = false
  }

  # k3s {
  #   extra_args {
  #     arg          = "--tls-san=${var.domain}"
  #     node_filters = ["agent"]
  #   }
  # }

  kubeconfig {
    update_default_kubeconfig = false
    switch_current_context    = false
  }

  # runtime {
  #   gpu_request = "all"
  # }
}

data "k3d_cluster" "this" {
  #name = var.cluster_name
  name       = k3d_cluster.this.name
  depends_on = [k3d_cluster.this]
}

resource "local_file" "kubeconfig" {
  content  = data.k3d_cluster.this.kubeconfig_raw
  filename = local.cluster_config
}

output "filename" {
  value = local_file.kubeconfig.filename
}

