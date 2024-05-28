locals {
  decoded_vault_yaml = yamldecode(module.ansible_vault.yaml)
}

data "cloudflare_zone" "zone" {
  name       = local.decoded_vault_yaml.domain
  depends_on = [
    module.ansible_vault
  ]
}