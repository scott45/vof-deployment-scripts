# Environment Creation

**Pre-requisites:**
Run this command in your terminal:
<kbd>**export TF_VAR_state_path="staging-state/terraform.tfstate"**</kbd>

The above command sets the environment variable **TF_VAR_state_path ** to that given value. This is the path in a GCS bucket that our terraform state file will be stored and the prefix of **TF_VAR_state_path ** for instance <kbd>staging</kbd> in <kbd>staging-state/terraform.tfstate</kbd> should always reflect the name of the environment being created for proper management of each environment state.

With that out of the way, run this command too
<kbd>**terraform init -backend-config="path=$TF_VAR_state_path" -var="env_name=environment name goes here"**</kbd>

The above command sets up the declared providers in your scripts, creates the terraform state file and then sets the GCS path.

With the above commands run successfully, we are now good to go forward with creating our environment(s).

Note: make sure you are running all these commands while you are in the directory which holds your terraform files. 

### Step 1:

Run <kbd>**terraform plan -var="env_name i.e environment name goes here" -var="vof_disk_image i.e image name that was created by packer or got from google images inventory goes here" -var="state_path=$TF_VAR_state_path"**</kbd> to have a glimpse of what the terraform scripts will create when you run the above command.

### Step 2:

At this point after confirming what the scripts will exactly do, it is safe to run: <kbd>**terraform apply -var="env_name=environment name goes here" -var="vof_disk_image=image name that was created by packer or got from google images inventory goes here" -var="state_path=$TF_VAR_state_path"**</kbd>This command goes on to create all the resources you have defined in the terraform scripts.

### Step 3:

Head over to the GCP console at **console.cloud.google.com** to check out your newly created VPC.

### Step 4:

In the event that you wish to destroy an environment, run: <kbd>**terraform destroy --force -var="env_name=environment name you want to destroy goes here" -var="vof_disk_image=image name that was created by packer or got from google images inventory goes here" -var="state_path=$TF_VAR_state_path"**</kbd> in your terminal. This will go on to destroy all resources related to the terraform scripts that lie in the folder in which you are running the commands.
> **Note:**
> - Always cd into the terraform folder (folder containing your terraform scripts) before you run the commands above.
> - If you add a provider or resource to any of the scripts, always run the terraform init command as described above first, so that it downloads and includes it in the state file.
> - Additionally always run the terraform plan command as described above to double check if what you want created will be the one created in the cloud.
