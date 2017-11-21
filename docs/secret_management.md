# Secret Management


## Tech stack

- Hashicorp Vault
- CentOS
- etcd


## Getting started

- Clone the infrastructure repository to your local box
- Download the json credentials from the VOF project console on Google Cloud Platform.
- Add the credentials to the `shared/account.json` file.
- Run the following commands
	- `cd vault/tf`
	- `export TF_VAR_vault_state_path=<gcs/path/to/terraform.tfstate>` default is state/vault/terraform.tfstate
	- `terraform init -backend-config="path=$TF_VAR_vault_state_path"`
	- `terraform apply -var="state_path=$TF_VAR_vault_state_path"`
- These series of commands will deploy the vault infrastructure to the GCP account


## Logging into Vault

#### SSH Access
- Using `gcloud`. Installation instructions here
	- Run `gcloud init` so as to set up the configuration credentials of the VOF application locally
	- Run `gcloud compute ssh <username>@<vault-vm-name> --zone "<vm-zone>"` to login via ssh


## Initial Setup

This section of Vault setup only needs to happen once;

#### Initialize vault

- `vault init`; This command will generate 5 shards of keys that are to be used in unsealing the vault along with 1 root token which must only be used during the initial setup and then revoked.
- The 5 keys and the root token must be kept safely as losing them would mean that the vault can never be unsealed and the secret inside will remain forever inaccessible. 

#### Unseal vault

Unsealing the vault means that the vault contents are no longer encrypted. However, this does not mean they are accessible just yet. For that you need to authenticate to the Vault service using the root token. To unseal vault, one needs to run the command below 3 times with 3 of the 5 shard keys that were generated in the previous command.
- `vault unseal <shard-key>`

#### Authenticate to Vault

This is the step that allows you to perform actions against the Vault backend. The access it time limited by default to 720Hrs after which time, the authentication will have to happen again.
- `vault auth <root-token>`


## Setting up Vault for VOF

#### Setting up policy

This refers to the capabilities that a particular user setup on Vault will have against the data or resources of the Vault backend.

```javascript
#create file acl.hcl

path "secret/*" {
  capabilities = ["create", "read"]
}
```

This policy means that what ever account is attached to this policy will be able to `create` and `read` data to and from the Vault backend.

Run `vault policy-write <editor-policy> <file/path/to/acl.hcl>` to create a policy called `editor-policy`.

#### Setting up authentication

There are several authentication backends that can be attached to Vault. VOF's Vault elected to use the one referred to as `userpass`. Below are the steps to setup the `userpass` authentication.

- Enable userpass `vault auth-enable userpass`
- Create user with password and policy; `vault write auth/userpass/users/<user> password=<user-pass> policies=<editor-policy>`

#### Setting up an audit backend

The audit backend feature is enable to allow the system administrator keep track of who has had access to the VOF Vault system. It is a useful source of information if/when the vault's security is compromised. This is how it is set up;

- Enable the audit backend; `vault audit-enable file file_path=/var/log/vault/vault_audit.log`
- The vault_audit.log file is created automatically during creation of the virtual machine that is hosting the Vault system. 

## Usage

### CLI

#### Write to secret backend
`vault write secret/production/password value=pass`

#### Read secret backend
`vault read secret/production/password` or `vault read -field=value secret/production/password`

### HTTP API

#### Write to secret backend

```
curl -X POST -H "X-Vault-Token: ...." \
     http://vault-address:8200/secret/production/password \
     -d {"value":"pass"}
```

#### Read secret backend

```
curl -X GET -H "X-Vault-Token: ...." \
     http://vault-address:8200/secret/production/password
```

#### Rails vault gem

Instructions on how to install and use this gem can be found [here](http://www.rubydoc.info/gems/vault/0.10.1)
