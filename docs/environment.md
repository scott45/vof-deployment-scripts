# Environment Creation

**Pre-requisites:**
- After cloing the repository, navigate to the `vof` folder; `cd vof`
- Export this variable in the terminal using; `export TF_VAR_state_path=path/to/<staging|production>/terraform.tfstate`

The above command sets the environment variable **TF_VAR_state_path** to that given value. This is the path in a GCS bucket that our terraform state file will be stored. The prefix of **TF_VAR_state_path** for instance `staging` in `path/to/staging/terraform.tfstate` should always reflect the name of the environment being created for proper management of each environment state and remember to reflect that change in `main.tf`

With that out of the way, run this command too

`terraform init -backend-config=path=<path/to/state/staging/terraform.tfstate> -backend-config=project=<gcp-project-id> -backend-config=bucket=<gcs-bucket-name> -var=env_name=<staging|production> -var=vof_disk_image=<packer-generated-image> -var=reserved_env_ip=<gcp-reserved-environment-ip>`

The above command sets up the declared providers in your scripts, creates the terraform state file and then sets the GCS path.

With the above commands run successfully, we are now good to go forward with creating our environment(s).

Note: make sure you are running all these commands while you are in the directory which holds your terraform files.

### Step 1:

Run the command below to have a glimpse of what the terraform scripts will create when you run the above command.

`terraform plan -var=state_path=<path/to/state/staging/terraform.tfstate> -var=project_id=<gcp-project-id> -var=bucket=<gcs-bucket-name> -var=env_name=<staging | production> -var=vof_disk_image=<packer-generated-image> -var=reserved_env_ip=<gcp-reserved-environment-ip> -var=service_account_email=<service-account-email-with-logging-capabilities> -var=slack_channel=<slack-channel> -var=slack_webhook_url=<slack-channel-hook> var=cable_url=<cable-url>  -var=redis_ip=<redis-ip-address> -var=bugsnag_key=<bugsnap_api_key>`
`

### Step 2:

Run the command below to create all the resources that have been defined in the terraform scripts.

`terraform apply -var=state_path=<path/to/state/staging/terraform.tfstate> -var=project_id=<gcp-project-id> -var=bucket=<gcs-bucket-name> -var=env_name=<staging | production> -var=vof_disk_image=<packer-generated-image> -var=reserved_env_ip=<gcp-reserved-environment-ip> -var=service_account_email=<service-account-email-with-logging-capabilities> -var=slack_channel=<slack-channel> -var=slack_webhook_url=<slack-channel-hook> var=cable_url=<cable-url> -var=env_url=<env-url> -var=redis_ip=<redis-ip-address> -var=bugsnag_key=<bugsnap_api_key>`
`


### Step 3:

Head over to the GCP console at **console.cloud.google.com** to check out your newly created VPC.

### Step 4:

In the event that you wish to destroy an environment.

`terraform destroy --force -var=state_path=<path/to/state/staging/terraform.tfstate> -var=project_id=<gcp-project-id> -var=bucket=<gcs-bucket-name> -var=env_name=<staging | production> -var=vof_disk_image=<packer-generated-image> -var=reserved_env_ip=<gcp-reserved-environment-ip> -var=service_account_email=<service-account-email-with-logging-capabilities> -var=slack_channel=<slack-channel> -var=slack_webhook_url=<slack-channel-hook> -var=cable_url=<cable-url> -var=redis_ip=<redis-ip-address> -var=bugsnag_key=<bugsnap_api_key>`


> **Note:**
> - Always cd into the terraform folder (folder containing your terraform scripts) before you run the commands above.
> - If you add a provider or resource to any of the scripts, always run the terraform init command as described above first, so that it downloads and includes it in the state file.
> - Additionally always run the terraform plan command as described above to double check if what you want created will be the one created in the cloud.
