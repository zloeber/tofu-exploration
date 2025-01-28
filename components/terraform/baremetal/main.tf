
data "local_file" "inventory_hosts" {
  filename = "${path.module}/inventory/hosts.yml"
}

locals {
  hosts = yamldecode(data.local_file.inventory_hosts.content)
}

resource "ansible_host" "dynamic_hosts" {
  for_each = local.hosts

  name   = each.key
  groups = each.value.groups

  variables = each.value.variables
}

resource "ansible_playbook" "prepare" {
  for_each = ansible_host.dynamic_hosts
  playbook   = "cluster-prepare.yml"
  name       = each.key
  replayable = true

  extra_vars = each.value.variables
}

resource "ansible_playbook" "installation" {
  playbook   = "cluster-installation.yml"
  name       = "dynamic_hosts"
  replayable = true

  extra_vars = {
    var_a = "Some variable"
    var_b = "Another variable"
  }
  depends_on = [ ansible_playbook.prepare ]
}