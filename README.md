# tf-kubernetes-kind

This is a minor demo of Hashicorp terraform module that can modify kubernetes resources

This demo is based on the tutorial of
Hashicorp [Manage Kubernetes resources via Terraform](https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-provider)
for kind.

## Prerequisites

The user needs to have pre-installed the following packages:

* [kind](https://kind.sigs.k8s.io/)
* [terraform-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [kubectl ](https://kubernetes.io/docs/tasks/tools/)

### Providers

This Tutorial aims to start using the terraform kubernetes
provider [terraform/kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest).

Sample of code:

````bash
module "ansible_vault" {
  source              = "./Ansible/modules/Vault"
  vault_file          = var.vault_file
  vault_password_file = var.vault_password_file
}

module "cloudflare_record" {
  source  = "./Cloudflare/modules/Record"
  zone_id = data.cloudflare_zone.zone.id
  name    = "www"
  value   = "203.0.113.1"
  type    = "A"
  proxied = true
}
````

### How to get the Certificates for Kind

Sample from command line:

````bash
$ kubectl config view --minify --flatten --context=kind-terraform-learn
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://127.0.0.1:37249
  name: kind-terraform-learn
contexts:
- context:
    cluster: kind-terraform-learn
    user: kind-terraform-learn
  name: kind-terraform-learn
current-context: kind-terraform-learn
kind: Config
preferences: {}
users:
- name: kind-terraform-learn
  user:
    client-certificate-data: ...
    client-key-data: ...
````

### How to read the sensitive data beforehand

Unfortunately we do need to use target resources so we can load the encrypted file first.

Sample of code:

````bash
$ terraform plan -out planOutput -target="module.ansible_vault"

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.ansible_vault.ansible_vault.vault will be created
  + resource "ansible_vault" "vault" {
      + args                = (known after apply)
      + id                  = (known after apply)
      + vault_file          = "vault.yml"
      + vault_password_file = "~/.vault_password_file"
      + yaml                = (sensitive value)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error message.
╵

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: planOutput

To perform exactly these actions, run the following command to apply:
    terraform apply "planOutput"
````

Then apply. Sample of code:

````bash
$ terraform apply "planOutput"
module.ansible_vault.ansible_vault.vault: Creating...
module.ansible_vault.ansible_vault.vault: Creation complete after 0s [id=vault.yml]
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested in the configuration may have been ignored and the output values may not be fully updated. Run the following command to verify that no other changes are
│ pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error message.
╵

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
````

Then we can deploy any kind of resources. Sample of code:

````bash
$ terraform plan -out planOutput
module.ansible_vault.ansible_vault.vault: Refreshing state... [id=vault.yml]
data.cloudflare_zone.zone: Reading...
data.cloudflare_zone.zone: Read complete after 1s [id=b483c62776a6cef229e28c66178842e2]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.cloudflare_record.cloudflare_record.record will be created
  + resource "cloudflare_record" "record" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "www"
      + proxiable       = (known after apply)
      + proxied         = true
      + ttl             = (known after apply)
      + type            = "A"
      + value           = "203.0.113.1"
      + zone_id         = "<zone id>"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: planOutput

To perform exactly these actions, run the following command to apply:
    terraform apply "planOutput"
````

### How to encrypt and edit Ansible keyvault files

Sample of code:

````bash
$ ansible-vault create vault.yml
domain: "example.com"
api_token: "<api token>"
````

````bash
$ ansible-vault edit vault.yml
domain: "example.com"
api_token: "<api token>"
````