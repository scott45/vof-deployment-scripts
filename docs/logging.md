# Logging

## Tech Stack
- Google-fluentd

## Setting Up Logging for VOF using Google Stackdriver and Google-fluentd

### Prerequisites

- Create a [service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) that has logging roles enabled.

![screenshot](screenshots/logging_roles1.png?raw=true "Logging Roles in Service Account")
- This can be done in the IAM section of the GCP [console](console.clound.google.com).

![screenshot](screenshots/iam_menu1.png?raw=true "The IAM Menu on GCP")

- As you create the service account, do not forget to download the service account keys. As these are the ones that grant access to any cloud resources your machines or application wishes to make use of. If you see a page such as this:

![screenshot](screenshots/choose_right_project1.png?raw=true "Choosing the Right Project")

- Make sure you are accessing the correct project and if you already are, double check if you have admin right to that project.

- Make sure to explicitly tell the instance which service account to use as explained [here](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances), else it will use the default service account. But If you do not wish to create a new service account(bad practice), add the logging permissions onto the default service account. This is done from the IAM & admin section of the [GCP console](https://console.cloud.google.com/iam-admin/iam/). Still, make sure you have admin right to the given project else you will not see this screen:

![screenshot](screenshots/editing_roles1.png?raw=true "Editing IAM Roles Console Screen")


### Enabling logging for your application and VM instances

- 1. For this project we used [Terraform](https://www.terraform.io) to build our VPC, just like documentation states [here](https://www.terraform.io/docs/providers/google/r/compute_instance.html), add the `service account` argument to the instance template resource in the terraform script, then add the email of the [service account](https://www.packer.io/docs/builders/googlecompute.html) that has the logging roles as demonstrated above then  add the logging scopes too as explained [here](https://cloud.google.com/logging/docs/access-control). This is enough to give logging permissions to all our instances that will be created.

- 2. Install the logging agents as follows:

![screenshot](screenshots/logging_installation.png?raw=true "Setting production environment variables")

- whether you are using packer to build your images or just SSH-ing into the VM instances, run the following commands in the VM instance terminal. For packer add it to a bash script and add that script as a `shell provisioner` in the packer script.

- 3. If you are not using an image builder like packer, SSH into the VM instance and `cd` into `/etc/google-fluentd/config.d` folder. Create a `*.conf` file. This file will hold the application logging configurations. The configurations look like below but enclosed between the opening and closing `source` tags;
>
    @type tail
    format none
    path /path/to/application/logs/development.log
    pos_file /var/lib/google-fluentd/pos/vof.pos
    read_from_head true
    tag vof_development_logs


- 4. For a reference on how to write this configuration file, take a look at [this](https://docs.fluentd.org/v0.12/articles/config-file)
		
- 5. Save the file and cd into `/var/lib/google-fluentd/pos` folder and add a `*.pos` file, this is the file fluentd uses to track the last read position of the log files. It can hold many log file "last read" positions, so one file can hold all your logs position configurations.

- 6. The contents of this file look like `/var/home/logs/google.log 000000000 00000000` where  `/var/home/logs/google.log` is the path to the log file and the zeros are the current read position. This value will change every time fluentd reads the logs.

- 7. With that set, restart the google-fluentd service by running the following command in your terminal `sudo service google-fluentd restart`.

- If you are using an image builder like packer, i suggest you write a bash script and include all the above steps from 2 like this:

![screenshot](screenshots/config1.png?raw=true "Configurations")

![screenshot](screenshots/config21.png?raw=true "Configurations")

- and include that script in your packer `.json` file under the `shell provisioners`. This script will then run when an instance created from this packer built image is started.

- When the instance is up and running, head over to the google console logging section, select the GCE VM instance you have created and the configured application and system logs will be there.


`Happy Logging`
