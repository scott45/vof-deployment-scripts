# Infrastructure

## Setup and utilization

### Infrastructure code
The infrastructure code is devided into 2 main branches, `master` and `develop`. These are their characteristics;
- Both branches are protected so you can not push changes directly to them. A feature/chore and bug branches in the format of `ft-name-of-feature`, `ch-name-of-chore` and `bug-name-of-bug` will be created and when ready a PR raised when attempting to make updates to the main branches.
- The `develop` branch has cutting edge changes to the infrastructure and only affects the `vof-migration-test` GCP project where infrastructure changes can be deployed and tested.
- The `master` branch contains the code promoted from `develop` and is what the production `vof-tracker` project uses. Be very careful with it.

### CircleCI
This is the hosted Continuous Integration(CI)/Continuous Deployment(CD) solution that was selected to build, test and deploy the VOF application. Version 2.0 is the latest iteration in the CI and it comes with many useful features;
- Use of docker images that let one customize the testing environment for any project.
- Workflow feature that allows user to visualize the flow of code through the various steps/jobs i.e. build, test and deployment.
- Approval jobs that let a user manually start some jobs which might require oversight.

#### Setting environment variables
- Log into CircleCI and click on the VOF project.
- Click on the settings icon for the project (_gear image_).
- Click on `Environment Settings` link which will provide an interface for entering environment variables.

Below are the required environments variables that should be set for the pipeline to work as expected. Most of them are used at the deployment stage;
1. **GCLOUD_VOF_BUCKET**: Google Cloud Storage(GCS) bucket where the terraform infrastructure file will be stored.
2. **GCLOUD_VOF_PROJECT**: Google Cloud Platform(GCP) project ID.
3. **PRODUCTION_DB_TIER**: Machine type that the database should be setup with. This value can be adjusted if in the future it is determined that the current machine in insufficient or is too big for its tasks.
4. **PRODUCTION_ENVS**: Setting the environment variables to be added to the production app's `application.yml` file.
5. **PRODUCTION_MAX_INSTANCES**: Maximum number of Virtual Machines(VM) that the production environment can scale to in case of high traffic to the site.
6. **PRODUCTION_RESERVED_IP**: GCP VOF project's production environment reserved global static IP.
7. **SERVICE_ACCOUNT**: Service account with a privileged IAM role that allows the deployment script to setup the network on the GCP project.
8. **SERVICE_ACCOUNT_EMAIL**: Email address that comes with the service account.
9. **SLACK_CHANNEL**: Slack channel where to send success or failure messages from the pipeline.
10. **SLACK_CHANNEL_HOOK**: Webhook that will allow the pipeline to sent messages to the slack channel above.
11. **STAGING_ENVS**: Setting the environment variables to be added to the staging app's `application.yml` file.
12. **STAGING_RESERVED_IP**: GCP VOF project's staging environment reserved global static IP.
13. **VOF_INFRASTRUCTURE_REPO**: Github link to the VOF infrastructure codebase.
14. **DESIGN_V2_RESERVED_IP**: GCP VOF project's design-v2 environment reserved global static IP.
15. **SANDBOX_RESERVED_IP**: GCP VOF project's sandbox environment reserved global static IP.
16. **CABLE_URL**: The cable url of the project. example wss://<the-vof-domain-name>/cable
17. **REDIS_IP**: The GCP redis ip address of the redis instance.
18. **BUGSNUG_KEY**: This is the apikey that is generated once you integrate the application with bugsnag
#### Setting production and staging run-time environment variables in CircleCI
![production_envs](screenshots/production_envs.png?raw=true "Setting production environment variables")

![staging_envs](screenshots/staging_envs.png?raw=true "Setting staging environment variables")

### SSH access
- Install and setup [gcloud](https://cloud.google.com/sdk/docs/quickstart-mac-os-x). This is useful when accessing VOFs infrastructure via SSH from your local box. Follow the instruction on the provided link. _Instructions to setup on different OSes can be found on the same link._
- This can also be done on Google Console. Each environment has a jumpbox VM that can gain SSH access to the VOF application VMs.

#### Usage
- `gcloud init`: To setup the default GCP project that you will be working with from the local box. This has to be run again if you have other projects you want access to.
- `gcloud compute ssh <firstname_lastname>@staging_jumpbox --zone europe-west1-b`: To gain access to the staging environment jumpbox
- `gcloud compute ssh <firstname_lastname>@production_jumpbox --zone europe-west1-b`: To gain access to the production environment jumpbox
- `gcloud compute instances list`: To list all VMs on the network.
- `gcloud compute ssh <firstname_lastname>@<name_of_vm> --zone europe-west1-b`: To gain access to a specific VM listed by the previous command. Depending on which jumpbox you SSHed into, you will only be able to access the VMs of that specific environment i.e either staging or production.

## Infrastructure code content
From this point onwards the documentation aims to guide any DevOps engineers that join the VOF team through how exactly the infrastructure files come together and what they do. The following describes what each terraform file/script does when setting up the infrastructure;

### compute.tf
- This scripts defines:
    - the backend service using the *google_compute_backend_service* terraform resource. This is the VPC load balancer that handles traffic from external sources, i.e, the world. The backend service has been set to use session cookies to achieve session affinity. Ideally this reconfigures the round robin algorithm of the load balancer, where one client's session will transmit data to only one instance during his/her session. This implementation was necessitated by the csrf architecture of the vof application. To prevent loss of affinity, it is necessary that it's mitigated by ensuring that the minimum number of instances provisioned by autoscaling is enough to handle expected load, then only using autoscaling for unexpected increases in load.
    - the instance group manager using the *google_compute_instance_group_manager* terraform resource. This is resource that creates and manages a pool of instances we have running at any given time in the cloud.
    - the instance template using the *google_compute_instance_template* terraform resource. Just as the name suggests, it is a template from which a new instance is created, on demand. It is made use of by the *google_compute_instance_group_manager*.
    - the autoscaler using the google_compute_autoscaler terraform resource. Just as the name suggests, it automatically adds or removes virtual machines from a managed instance group based on increases or decreases in load. This allows applications to gracefully handle increases in traffic and reduces cost when the need for resources is lower. All you do is just to define the autoscaling policy and the autoscaler performs automatic scaling based on the measured load.
    - and a healthcheck to monitor the health of our infrastructure and instance using the *google_compute_http_health_check* resource. This is used to monitor instances behind load balancers. It monitors their health, whereby timeouts or HTTP errors cause the instance to be removed from the pool.

### database.tf
- This script does the following:
    - Generates a random number. The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources. In our case we generate 2 random numbers, one of 8 byte length, and another for a 16 byte length, to be used for database name and password respectively.
    - Creates an SQL database instance using the specified arguments as seen on the terraform google_sql_database_instance page  This is the machine instance on which our postgres database will reside.
    - Creates a new Google SQL Database on a Google SQL Database Instance.
    - Creates a new Google SQL database user and assigns the above randomly created name and password to it.
    - And then outputs the username, password and database IP address to the admin on the console in which the scripts are run since these are randomly generated.

### main.tf
- This script does the following:
    - Defines the provider we are using in all the scripts, in this case, “Google”. The Google Cloud provider is used to interact with Google Cloud services. The provider needs to be configured with the proper credentials before it can be used. The credentials here are the service account keys.
    - A terraform backend service. This stores the terraform state from our local storage to a given bucket on Google Cloud Storage.
    - And a data resource which retrieves the terraform state meta data from the remote storage where it was previously stored by the terraform backend resource. This is retrieved every time you run terraform plan, terraform apply or terraform destroy commands.

### network.tf
- This script does the following:
    -  creates and manages networks using the *google_compute_network* resource. These created networks are the ones we use in our cloud infrastructure.
    -  creates and manages subnetworks using the *google_compute_subnetwork* resource.
    - outputs/displays the private subnetwork name and network name to the console.

### routing.tf
- This script defines the:
    - creates a static IP address resource global to a Google Compute Engine project, in our case, it is  “*vof-environment-test*”. This is done using the *google_compute_global_address* resource.
    - global forwarding rule using the *google_compute_global_forwarding_rule*  resource. The global forwarding rule provides a single global IPv4 or IPv6 address that you can use in DNS records for your site.
    - http proxy using the *google_compute_target_http_proxy* resource. This resource creates a target HTTP proxy resource in GCE. Target proxies are referenced by one or more global forwarding rules. In the case of HTTP(S) load balancing, proxies route incoming requests to a URL map.
    - cloud url map using *google_compute_url_map* resource. Compute Engine HTTP(S) Load Balancing allows you to direct traffic to different instances based on the incoming URL. When a request comes into the load balancer, it is routed to backend services based on configurations in a URL map. Using host values (*andela.com*) and path values (*/path*) in the destination URL, the URL map forwards the request to the correct backend service.
    - firewalls, both internal and external and their rules. Google Cloud Platform (GCP) firewall rules protect your virtual machine (VM) instances from unapproved connections, both inbound (ingress) and outbound (egress). You can create firewall rules to allow or deny specific connections based on a combination of IP addresses, ports, and protocol.
    - and another firewall to let through healthcheck traffic.

### jumpbox.tf
- This script sets a VM that is capable of accessing, via SSH, the VMs in a particular environment. A staging environment jumpbox will only be able to access the VMs setup in the internal network of the staging environment and the same applies to the production jumpbox.
- This file is self contained and defines all the attributes that accrue to a jumpbox such as the GCE instance, the networking settings and the necessary firewall rules it needs to do its work.

### variables.tf
- This script declares and/or defines the terraform scripts’ variables. These variables are replacements in all the terraform scripts areas where we put a syntax that looks like *${some resource name here},* in technical terms, wherever we interpolated.
Additionally we created another folder called packer which contains a *.json* file that contains a packer script that is responsible for creating the image we shall use to create all instances for our application in the cloud. To create a packer image do the following;
 - In your terminal, “cd” into the packer folder, set the environment variable **VOF_PATH** to the path to the application’s local repository folder.
 - Run the command *“packer build packer.json*” to start the image creation process.
 - At the successful completion of the packer building process, an image will be created including all contents described in the **packer.json** script. For our case, that includes all the bash scripts such as the **“setup.sh”** and the **“start_vof.sh”**.
 - The **setup.sh** script sets up our VOF application code, creates necessary folders to store the code in the image, install all required dependencies for both the native OS of the server we are using, as well as the VOF application language dependencies.
 - Additionally a **.json** file that contains google service account keys.

_**PS: All this assumes that terraform and packer are installed on your local machine.**_