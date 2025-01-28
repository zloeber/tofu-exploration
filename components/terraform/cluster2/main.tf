resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

module "ssh_key" {
  source    = "../modules/self-signed-cert"
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
