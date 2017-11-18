# Monitoring

## Tech Stack
Stackdriver and google-fluentd

## Setting Up Monitoring for VOF using Google Stackdriver and Google-Fluentd

- Create a [service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) with keys that have monitoring roles included. Make sure to explicitly tell the instance which service account to use as explained [here](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances), else it will use the default service account. But If you do not wish to create a new service account(bad practice), add the monitoring permission onto the default service account.

- If you are not using an image builder like packer, SSH into the VM where you want to set up monitoring and install the Stackdriver gem in the VM instance of the application. Details on this are available on `https://cloud.google.com/error-reporting/docs/setup/ruby`. For this application, the Stackdriver Gem installation is included in the `setup.sh` file which includes all gems that are required to run VOF. Additionally add the monitoring agent as explained [here](https://cloud.google.com/monitoring/agent/install-agent) to the same file, as this will install them.

- For this project we used [Terraform](https://www.terraform.io) to build our VPC, just like documentation states [here](https://www.terraform.io/docs/providers/google/r/compute_instance.html), i added the `service account` argument to the instance template resource, then added the email of the service account i created and added the monitoring scope too. This is enough to give monitoring permissions to all our instances that will be created.

- Now head over to the stackdriver web interface [here](https://app.google.stackdriver.com/). While here, set up all the resources and metrics you would want to keep an eye on, and create a dashboard that contains all those for ease of access. The above setup will send data from your VMs and it will be displayed here.

- You can set up alert policies too. These alert you when the set thresholds/conditions are violated. The stackdriver web UI is pretty much straight forward on how to set up and confgure. 

## Haapy Monitoring