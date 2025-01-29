
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
      #enforced = true
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
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}