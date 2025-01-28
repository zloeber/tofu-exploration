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
    kind = {
      source  = "tehcyx/kind"
      version = "0.7.0"
    }
  }
  backend "local" {
  #  path = "../../../secrets/local/infrastructure_tfstate.json"
  }
}

## Kind cluster creation
module "clusters" {
  for_each = toset(var.clusters)
  source              = "../modules/k8s-kind-cluster"
  cluster_name        = each.key
  cluster_config_path = "../../../secrets/${var.env}/${each.key}_config"
}
