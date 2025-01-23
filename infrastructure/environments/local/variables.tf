variable "env" {
  description = "The environment to deploy to."
  type        = string
  default     = "local"
}

variable "argocd_namespace" {
  description = "The namespace to deploy ArgoCD."
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "The version of ArgoCD to install."
  type        = string
  default     = "stable"
}

variable "clusters" {
  description = "List of clusters to deploy ArgoCD."
  type        = list(string)
  default     = [ "cluster1", "cluster2" ]
}
