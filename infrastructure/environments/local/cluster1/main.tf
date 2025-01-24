terraform {
  required_version = ">= 1.9.0"
    encryption {
    ## Step 1: Add the desired key provider:
    key_provider "pbkdf2" "mykey" {
      passphrase = var.state_passphrase
    }
    ## Step 2: Set up your encryption method:
    method "aes_gcm" "passphrase" {
      keys = key_provider.pbkdf2.mykey
    }

    method "unencrypted" "insecure" {}
    state {
      # enforced = true
      method = method.aes_gcm.passphrase
      fallback {
        method = method.unencrypted.insecure
      }
    }
    plan {
      # enforced = true
      method = method.aes_gcm.passphrase
      fallback {
        method = method.unencrypted.insecure
      }
    }
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
  backend "local" {
    path = "../../../../secrets/local/cluster1_tfstate.json"
  }
}

variable "state_passphrase" {
  type = string
  description = "value of the passphrase used to encrypt the state file"
  validation {
    condition     = length(var.state_passphrase) >= 16
    error_message = "The passphrase must be at least 16 characters long."
  }
}

variable "env" {
  description = "The environment to deploy to."
  type        = string
  default     = "local"
}

variable "cluster_name" {
  description = "The name of the cluster to create."
  type        = string
}

variable "kubeconfig" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "key_path" {
  description = "Path to the directory where the SSH keys will be stored."
  type        = string
}
provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

module "ssh_key" {
  source    = "../../../modules/self-signed-cert"
  name      = var.cluster_name
  root_path = pathexpand(var.key_path)
}

resource "kubernetes_secret" "argocd_ssh_key" {
  metadata {
    name      = "argocd-ssh-key"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  data = {
    ssh-privatekey = module.ssh_key.private_key_pem
    ssh-publickey  = module.ssh_key.public_key_path
    # ssh-privatekey = base64encode(file(module.ssh_key.private_key_path))
    # ssh-publickey  = base64encode(file(module.ssh_key.public_key_path))
  }
  type = "kubernetes.io/ssh-auth"
  depends_on = [ module.ssh_key ]
}

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  create_namespace = false
  description      = "ArgoCD Helm Chart"
  name             = "argo"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  upgrade_install  = true
  values = [
    templatefile("${path.module}/config.yml", {
      argocd_server_url = "https://argocd-server.argocd.svc.cluster.local"
    })
  ]
  depends_on = [
    kubernetes_namespace.argocd,
  ]
  wait = false
}
