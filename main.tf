module "ansible_vault" {
  source              = "git@github.com:thanos1983/terraform.git//Ansible/modules/Vault"
  vault_file          = var.vault_file
  vault_password_file = var.vault_password_file
}

module "cloudflare_record" {
  source     = "git@github.com:thanos1983/terraform.git//Cloudflare/modules/Record"
  zone_id    = data.cloudflare_zone.zone.id
  name       = "www"
  value      = "203.0.113.1"
  type       = "A"
  proxied    = true
  depends_on = [
    module.ansible_vault
  ]
}