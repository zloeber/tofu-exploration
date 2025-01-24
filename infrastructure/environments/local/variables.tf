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

variable "state_passphrase" {
  type = string
  description = "value of the passphrase used to encrypt the state file"
  validation {
    condition     = length(var.state_passphrase) >= 16
    error_message = "The passphrase must be at least 16 characters long."
  }
}