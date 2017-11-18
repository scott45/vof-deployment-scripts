# Logging

## Tech Stack
Stackdriver and google-fluentd

## Setting Up Monitoring and Logging for VOF using Stackdriver

- Create a [service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) with keys that have logging and monitoring roles included. Make sure to explicitly tell the instance which service account to use as explained [here](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances), else it will use the default service account. But If you do not wish to create a new service account(bad practice), add the logging and monitoring permission onto the default service account.

- Install the Stackdriver gem in the VM instance of the application. Details on this are available on `https://cloud.google.com/error-reporting/docs/setup/ruby`. For this application, the Stackdriver Gem installation is included in the `setup.sh` file which includes all gems that are required to run VOF. Additionally add the monitoring and logging agents as explained [here](https://cloud.google.com/monitoring/agent/install-agent) to the same file, as this will install them.

- For this project we used terraform to build our VPC, just like documentation states [here](https://www.terraform.io/docs/providers/google/r/compute_instance.html), i added the `service account` argument to the instance template resource, then added the email of the service account i created and added the logging and monitoring scopes too. This is enough to give logging and monitoring permissions to all our instances that will be created.

- If you are not using an image builder like packer, SSH into the VM instance and `cd` into `/etc/google-fluentd/config.d` folder. Create a `*.conf` file. This file will hold the application logging configurations. The configurations look like;
                <source>
                    @type tail
                    format none
                    path /home/vof/app/log/development.log
                    pos_file /var/lib/google-fluentd/pos/vof.pos
                    read_from_head true
                    tag vof_development_logs
                </source>
		
- Save the file and cd into `/var/lib/google-fluentd/pos` folder and add a `*.pos` file, this is the file fluentd uses to track the last read position of the log files. It can hold many log file "last read" positions, so one file can hold all your logs position configurations.

- The contents of this file look like `/var/home/logs/google.log 000000000 00000000` where  `/var/home/logs/google.log` is the path to the log file and the zeros are the current read position. This value will change every time fluentd reads the logs.

- With that set, restart the google-fluentd service by running the following command in your terminal `sudo service google-fluentd restart`.

- At this point, we can now head to the google console logging section and the configured application logs will be there.

- If you are using an image builder like `packer`, do all those steps above, but now in a bash script. This script should then be included in the image that will be built and run, so that when an instance of that image is created, the script is run and allthose configurations take effect and then all you have to do is head to the logging section of the GCP console and the logs will be there.



