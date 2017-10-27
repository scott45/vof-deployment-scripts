# Vault on Google Clould

This is a demo project that will install a **[Vault][vault]** on **[Google Clould Platform][gCloud]** with **[Terraform][terraform]**.

**Vault** — a tool from HashiCorp for securely managing secrets and encrypting data in-transit. From storing credentials and API keys to encrypting passwords for user signups, Vault is meant to be a solution for all secret management needs.

**Google Cloud Platform** enables developers to build, test and deploy applications on Google’s highly-scalable and reliable infrastructure.

**Terraform** is a tool for creating, combining, and managing infrastructure resources across multiple providers. Manage resources on cloud providers such as Amazon Web Services, Google Cloud, Microsoft Azure, DNS records on DNSSimple, Dyn, and CloudFlare, email services on Mailgun, and more.

**High Availability** is achieved by using a [CoreOS Ectd Cluster][Etcd] as the storage backend of the Vault.

## Setup A Google Cloud Project

The start point for working on Google Clould Platform is **Project** (very engineering oriented).

The first thing we need to do is to create a new project at [Google Project Console][gProject], for example:

Project Name | Project ID
------------ | ----------
ProjectVault | vault-20160301

### Get Authentication JSON File

Authenticating with Google Cloud services requires a JSON file which is called the _account file_ in Terraform.

This file is downloaded directly from the [Google Developers Console][gProject]:

1. Click the menu button in the top left corner, and navigate to "Permissions", then "Service accounts", and finally "Create service account".

1. Provide **vault-20160301** as the name and ID in the corresponding fields, select "Furnish a new private key", and select "JSON" as the key type.

1. Clicking "Create" will download your credentials.

1. Rename the downloaded json file to **account.json**
**Note:** you'll be asked to setup billing infomation for this new project. If you are new user, Google gives you a `$300.00` GCP credit for 60 days. 

### Enable Google Cloud APIs for ProjectVault

To use and control google cloud with command line tools, we need to enable Google Cloud APIs.

Go to [Google Cloud API Manager][gAPI]
and enable Google Cloud APIs for ProjectVault:

* Compute Engine API
* Cloud Storage Service
* Cloud Deployment Manager API
* Cloud DNS API
* Cloud Monitoring API
* Cloud Storage JSON API
* Compute Engine Instance Group Manager API
* Compute Engine Instance Groups API
* Prediction API

**Note:** Not a state of the art UI/UX, just make sure the project is *ProjectVault* and click through the APIs to enable them.


## Install and Setup Tools

### Install Terraform

Following the instructions on [Installing Terraform][installing-terraform] to install Terraform

**Tip:** for MacOS users, just `brew install terraform`

### Install Google Cloud SDK
Google Cloud SDK comes with a very useful CLI utility 
**gcloud**. We may need it to login and check on the vault cluster.

Following [Google Cloud SDK Instructions][gSDK] to install Google Cloud SDK

### Initialize gcloud configuration
```
$ gcloud init --console-only
Welcome! This command will take you through the configuration of gcloud.
...
gcloud has now been configured!
You can use [gcloud config] to change more gcloud settings.

Your active configuration is: [default]

[compute]
region = us-central1
zone = us-central1-a
[core]
account = youraccount@gmail.com
disable_usage_reporting = True
project = vault-20160301
```

### Install Vault Client On Local Machine

Download pre-compiled binary at [Download Vault Page][vault-download], or run:
```
$ (mkdir -p ~/bin; cd ~/bin; curl -O https://releases.hashicorp.com/vault/0.5.1/vault_0.5.1_darwin_amd64.zip && unzip vault_0.5.1_darwin_amd64.zip && rm vault_0.5.1_darwin_amd64.zip )
```

## Provision the Vault on Google Cloud
```shell
$ git clone https://github.com/xuwang/gcp-vault.git
$ cp account.json gcp-vault/tf/
$ cd gcp-vault/tf
```
**Note:** You should check default values defined in **tf/variables.tf** and make modification to fit your own case, e.g. use your own **`google_project_id`** instead of the default _`vault-20160301`_.

#### Plan and apply the terraform managed resources

Run terraform plan to preview what resources will be created:

```
$ terraform plan 
...
+ google_compute_address.vault_service ...
+ google_compute_firewall.vault-allow-service ...
+ google_compute_forwarding_rule.vault ...
+ google_compute_http_health_check.vault ...
+ google_compute_instance.vault.0 ...
+ google_compute_instance.vault.1 ...
+ google_compute_instance.vault.2 ...
+ google_compute_target_pool.vault ...
+ template_file.cloud_config ...
+ template_file.etcd_discovery_url ...
...
Plan: 10 to add, 0 to change, 0 to destroy.
```

If everything looks good and no error shown, apply the terraform:

```shell
$ terraform apply
...
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

  vault_service_ip = 104.154.88.124
```

Give a few munites, the vault cluster should be up and running on Google cloud:

```
 $ gcloud compute instances list
NAME    ZONE          MACHINE_TYPE  PREEMPTIBLE INTERNAL_IP EXTERNAL_IP     STATUS
vault-1 us-central1-a n1-standard-1             10.128.0.2  146.148.104.177 RUNNING
vault-3 us-central1-c n1-standard-1             10.128.0.4  23.236.51.9     RUNNING
vault-2 us-central1-b n1-standard-1             10.128.0.3  104.154.82.96   RUNNING
```

## Initialize Vault Servers 
### Use gcloud to login Vault servers:

```shell
$ gcloud compute --project "vault-20160301" ssh -A --zone "us-central1-a" "vault-1"
...
CoreOS stable (835.9.0)
```
**Note:** If this is your first login, _gcloud_ command will generate public/private rsa key pair named _google_compute_engine_ and save it under ~/.ssh directory. To use it for ssh forwarding, logout and then:

```
$ ssh-add ~/.ssh/google_compute_engine
```

### Initialize the Vault

Initialization is the process of first configuring the Vault. This only happens once when the server is started against a new backend that has never been used with Vault before.

See [ Initialize the Vault ] (https://www.vaultproject.io/intro/getting-started/deploy.html)

```shell
$ vault init
Key 1: 0bc5b079200bcbaf8d1af0e6ad7cb166fb77873ef5ddf60e7f1687f110c6c18901
Key 2: 1024f60e2c20b53f7942883e373afa72049baa60c578e767f8af76ab1238cc8a02
Key 3: 66553054a2d3dc8305527caa57f65b1394534ece64adcdca62c19596dec171cf03
Key 4: 955c312b93c7b56c2121e00dca9b2507fe7d828160c10d1217e1517674a46e5d04
Key 5: e32df7711d34dcd05d311499aa5784666eb5662fc11427bf8d8fb24bb85dd31805
Initial Root Token: af3db37d-251c-01c7-4d23-4801660d81d9

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the Vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your Vault will remain permanently sealed.
```

**! Warning:** Please save above keys and the *Initial Root Token* in safe places. 5 keys should not be keeped in the same place.

### Unseal Vault Servers
When a Vault server is started, it starts in a sealed state. In this state, Vault is configured to know where and how to access the physical storage, but doesn't know how to decrypt any of it.

Unsealing is the process of constructing the master key necessary to read the decryption key to decrypt the data, allowing access to the Vault.

See [Seal/Unseal Vault] (https://www.vaultproject.io/docs/concepts/seal.html)

Ssh to each Vault server, i.e. vault-1, vault-2, vault-3 do vault unseal:

```shell
$ vault unseal <Key 1>
Sealed: true
Key Shares: 5
Key Threshold: 3
Unseal Progress: 1

$ vault unseal <Key 2>
Sealed: true
Key Shares: 5
Key Threshold: 3
Unseal Progress: 2

$ vault unseal <Key 3>
Sealed: false
Key Shares: 5
Key Threshold: 3
Unseal Progress: 0

$ vault status
Sealed: false
Key Shares: 5
Key Threshold: 3
Unseal Progress: 0

High-Availability Enabled: true
	Mode: active
	Leader: http://<leader_ip>:8200
```
Now the Vault is ready to serve. 

See [Introduction to Vault] (https://www.vaultproject.io/intro/) for usage examples.

## Cleanup: Destroy the Vault Cluster

If you want to **stop paying google for Vault**, remember to clean it up:

**! Warning:** Make sure you saved all your secrets somewhere else before you destroy the Vault!


```shell
$ terraform destroy
...

Apply complete! Resources: 0 added, 0 changed, 10 destroyed.
```


## Technical Notes
* Security
	* Google Cloud Platform
	* CoreOS
	* Vault
* High Availability
	* Google Cloud Platform
	* Etcd cluster as storage backend
	* Vault cluster behind load balancer
* Ssh backend is not working on CoreOS because PAM is not supported on CoreOS

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[using-coreos]: http://coreos.com/docs/using-coreos/
[installing-terraform]: https://www.terraform.io/intro/getting-started/install.html
[gProject]: https://console.cloud.google.com/project
[gSDK]: https://cloud.google.com/sdk/
[gAPI]: https://console.cloud.google.com/apis
[vault]: https://www.hashicorp.com/blog/vault.html
[gCloud]: https://cloud.google.com/
[terraform]: https://www.terraform.io/
[CoreOS]: https://coreos.com/
[vault-download]: https://www.vaultproject.io/downloads.html
[Etcd]: https://coreos.com/etcd/
