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

# variable "chart_values" {
#   description = "Values to be passed to the Helm chart"
#   type        = map(any)
#   default     = {}
# }

variable "stage" {
  description = "The stage to deploy to."
  type        = string
  default     = "dev"
}