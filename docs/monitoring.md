# Monitoring

### Tech Stack

- Stackdriver 
- google-fluentd


### Setting Up Monitoring for VOF using Google Stackdriver and Google-Fluentd

- Create a [service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) with keys that have monitoring roles included. Make sure to explicitly tell the instance which service account to use as explained [here](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances), else it will use the default service account. But If you do not wish to create a new service account(bad practice), add the monitoring permission onto the default service account.

- If you are not using an image builder like packer, SSH into the VM where you want to set up monitoring and install the Stackdriver gem in the VM instance of the application. Details on this are available on `https://cloud.google.com/error-reporting/docs/setup/ruby`. For this application, the Stackdriver Gem installation is included in the `setup.sh` file which includes all gems that are required to run VOF. Additionally add the monitoring agent as explained [here](https://cloud.google.com/monitoring/agent/install-agent) to the same file, as this will install them.

- For this project we used [Terraform](https://www.terraform.io) to build our VPC, just like documentation states [here](https://www.terraform.io/docs/providers/google/r/compute_instance.html), i added the `service account` argument to the instance template resource, then added the email of the service account i created and added the monitoring [scope](https://cloud.google.com/monitoring/access-control) too. This is enough to give monitoring permissions to all our instances that will be created.

- Now head over to the stackdriver web interface [here](https://app.google.stackdriver.com/). While here, set up all the resources and metrics you would want to keep an eye on, and create a dashboard that contains all those for ease of access. The above setup will send data from your VMs and it will be displayed here.

- You can set up alert policies too. These alert you when the set thresholds/conditions are violated. The stackdriver web UI is pretty much straight forward on how to set up and confgure. 


### Usage
- On the Stackdriver home page, there are a number of things that you can interact with such as buttons for `Create Check`, `Create Policy` and `Create Dashboard`. 

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/1.png) 

- For this project, an uptime health check is used monitor the uptime health of the application by sending a  request to a URL, a VM instance, or other resource on a regular basis. If the resource fails to successfully respond to a request sent from at least two geographic locations, the uptime check fails. 

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/2.png) 

- In this case, a HTTP uptime check is set and from the look of things, it passes in all regions making it successful. 

- Another uptime check can be created by clicking on the `add uptime check` button which is on the topside right of the image above which results into:

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/3.png) 

- After creating an Uptime Check, there is a prompt to create a policy but you can opt not to and create a policy later when policies are clear.

- For this application, there are several different policies. To create a policy, click on `Create Policy`. A policy basically defines the conditions under which a service is considered unhealthy and when these conditions are met, the policy gets triggered and an incident is opened. The incident is then tasked with sending a notification via Slack, SMS, or whichever means you configured.

- Here’s how to create a policy:
![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/4.png) 

- On Conditions, you can create a condition by declaring the different metrics that need be monitored such as metric threshold, metric absence, metric rate of change, uptime health check and process health. Since `VOF HTTP UPTIME CHECK` was created, an uptime health check is created to check that the resource does not fail to successfully respond to a request sent from at least two geographical locations.

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/5.png) 

- This checks that it is not down for at most 5 minutes which is the lowest time you can set for this condition. Then click on `Save Condition`.

- Back on the Policies page, click on the `Add Notification` button which enables you select the medium via which alerts/notifications should be sent and also the address if you select email. 

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/6.png) 

- To include other metrics, click on the `Add Another Condition` button on the policies page. If you click on the `Select` button on the Metric Threshold part, you will see this:

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/7.png) 

- It is also possible to set monitoring for Disk Read Write in the Metric Threshold by selecting from the dropdown list under `IF METRIC`. The result will look like this:

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/9.png) 

- To monitor metric absence, click on the second basic type and the resulting screen will look like this:

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/13.png) 

- For example, an alert is triggered if there is no outgoing traffic for a period of 30 minutes.

- To observe Metric Rate of Change, select the third option on Basic Types which is quite similar to setting the other metrics. In this case, there is no graph to show anything just adjustable metrics to be observed.

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/8.png) 

- There is a documentation part which should have the details of all the policies included to bring clarity to those who might be new to the team with little to no understanding of the error alerts.

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/12.png) 

- A view of all the policies will be on the `Policies Overview` page which open when you select on it from the Alerting that is on the left of the screen

![screenshot](https://github.com/FlevianK/vof-terraform/blob/master/docs/screenshots/14.png) 

- You can create as many policies as you want separately especially if you have more than one environment. This will help in identifying where exactly a problem is arising from.



`Happy Monitoring`