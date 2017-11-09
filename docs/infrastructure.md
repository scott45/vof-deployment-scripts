# Infrastracture

# VOF Google Cloud Platform Infrastructure
As the DevOps team, we have created a total of 7 files in one given folder, 6 of which are terraform scripts, and the remaining 1 is a file,, which is a *.json* file contains the GCP service account keys. The tool we are using here is packer and terraform.
In the following steps i will describe what each terraform file/script does.
### 1. compute.tf
-------------------
- This scripts defines:
    
    - the backend service using the *google_compute_backend_service* terraform resource. This is the VPC load balancer that handles traffic from external sources, i.e, the world.
    - the instance group manager using the *google_compute_instance_group_manager* terraform resource. This is resource that creates and manages a pool of instances we have running at any given time in the cloud.
    - the instance template using the *google_compute_instance_template* terraform resource. Just as the name suggests, it is a template from which a new instance is created, on demand. It is made use of by the *google_compute_instance_group_manager*.
    - the autoscaler using the google_compute_autoscaler terraform resource. Just as the name suggests, it automatically adds or removes virtual machines from a managed instance group based on increases or decreases in load. This allows applications to gracefully handle increases in traffic and reduces cost when the need for resources is lower. All you do is just to define the autoscaling policy and the autoscaler performs automatic scaling based on the measured load.
    - and a healthcheck to monitor the health of our infrastructure and instance using the *google_compute_http_health_check* resource. This is used to monitor instances behind load balancers. It monitors their health, whereby timeouts or HTTP errors cause the instance to be removed from the pool.
### 2. database.tf
-----------------
- This script does the following:
    
    - Generates a random number. The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources. In our case we generate 2 random numbers, one of 8 byte length, and another for a 16 byte length, to be used for database name and password respectively.
    - Creates an SQL database instance using the specified arguments as seen on the terraform google_sql_database_instance page  This is the machine instance on which our postgres database will reside.
        
    - Creates a new Google SQL Database on a Google SQL Database Instance.
        
    - Creates a new Google SQL database user and assigns the above randomly created name and password to it. 
         
    - And then outputs the username, password and database IP address to the admin on the console in which the scripts are run since these are randomly generated.
### 3. main.tf
-------------
- This script does the following:
        
    - Defines the provider we are using in all the scripts, in this case, “Google”. The Google Cloud provider is used to interact with Google Cloud services. The provider needs to be configured with the proper credentials before it can be used. The credentials here are the service account keys. 
        
    - A terraform backend service. This stores the terraform state from our local storage to a given bucket on Google Cloud Storage.
        
    - And a data resource which retrieves the terraform state meta data from the remote storage where it was previously stored by the terraform backend resource. This is retrieved every time you run terraform plan, terraform apply or terraform destroy commands.
 
### 4. network.tf
-------------
- This script does the following:
    -  creates and manages networks using the *google_compute_network* resource. These created networks are the ones we use in our cloud infrastructure.
        
    -  creates and manages subnetworks using the *google_compute_subnetwork* resource. 
        
    - outputs/displays the private subnetwork name and network name to the console.
        
### 5. routing.tf
-------------
- This script defines the:
    - creates a static IP address resource global to a Google Compute Engine project, in our case, it is  “*vof-environment-test*”. This is done using the *google_compute_global_address* resource.
        
    - global forwarding rule using the *google_compute_global_forwarding_rule*  resource. The global forwarding rule provides a single global IPv4 or IPv6 address that you can use in DNS records for your site.  
        
    - http proxy using the *google_compute_target_http_proxy* resource. This resource creates a target HTTP proxy resource in GCE. Target proxies are referenced by one or more global forwarding rules. In the case of HTTP(S) load balancing, proxies route incoming requests to a URL map.  
        
    - cloud url map using *google_compute_url_map* resource. Compute Engine HTTP(S) Load Balancing allows you to direct traffic to different instances based on the incoming URL. When a request comes into the load balancer, it is routed to backend services based on configurations in a URL map. Using host values (*andela.com*) and path values (*/path*) in the destination URL, the URL map forwards the request to the correct backend service.
        
    - firewalls, both internal and external and their rules. Google Cloud Platform (GCP) firewall rules protect your virtual machine (VM) instances from unapproved connections, both inbound (ingress) and outbound (egress). You can create firewall rules to allow or deny specific connections based on a combination of IP addresses, ports, and protocol. 
        
    - and another firewall to let through healthcheck traffic.
### 6. variables.tf:
-------------
- This script declares and/or defines the terraform scripts’ variables. These variables are replacements in all the terraform scripts areas where we put a syntax that looks like *${some resource name here},* in technical terms, wherever we interpolated.
---
Additionally we created another folder called packer which contains a *.json* file that contains a packer script that is responsible for creating the image we shall use to create all instances for our application in the cloud. To create a packer image do the following;
 - In your terminal, “cd” into the packer folder, set the environment variable **VOF_PATH** to the path to the application’s local repository folder.
 
 - Run the command *“packer build packer.json*” to start the image creation process.
 
 - At the successful completion of the packer building process, an image will be created including all contents described in the *packer.json* script. For our case, that includes all the bash scripts such as the *“setup.sh”* and the *“start_vof.sh”*. 
 
 - The *setup.sh* script sets up our VOF application code, creates necessary folders to store the code in the image, install all required dependencies for both the native OS of the server we are using, as well as the VOF application language dependencies.
 - Additionally a *.json* file that contains google service account keys.
        NOTE: All this while i am assuming you have installed terraform and packer in your local machine.