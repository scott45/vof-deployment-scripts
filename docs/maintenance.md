# System Maintenance Documentation
To keep the system on which VOF is running healthy and robust, it is important that some maintenance tasks are carried out. These tasks aim to:
- Keep the host OS secure by updating system packages and getting the latest security patches.
- Ensuring that storage space is conserved by running automated tasks to clean up the system.

## Implementation
- There is a cronjob that is added via a script that runs `unattended_upgrades` on the OS to get the latest packages and security fixes.
- Log rotate package is installed on the system to keep the sizes of the system/application logs in check.
- Mailgun is also configured to enable the GCP instances to send email notifications when system maintenance is done.

### Running unattended_upgrades
This was achieved by Creating a crontab that runs unattended upgrades regularly using the command: `unattended-upgrade`.
The unattended_upgrades package is installed among other system dependencies in the setup.sh file.
Below is an example of the cronjob

>0 9 * * * curl -X POST --data-urlencode "payload={\"channel\": \"#channel\", \"username\": \"unattended-upgrades\", \"text\": \"*Unattended upgrades report from $(uname -n)*\n>>>$(sudo unattended-upgrade -v)\", \"icon_emoji\": \":bell:\"}" ${var.slack_hook_url}


 This crontab runs the command `unattended-upgrade ` at 0900hrs every day. It sends a slack notification to the specified Slack channel. uname-n adds the machine’s name to the subject.
This has been implemented using the `run_upgrades` function in the start_vof.sh file.
Checkout  more information on crontabs [here](http://www.adminschoice.com/crontab-quick-reference).

### Implementing logrotate
[Logrotate](https://linux.die.net/man/8/logrotate) will rotate logs daily and compress old logs and therefore minimize the amount of disk space used as well as the general cost.
below is a sample /etc/logrotate.conf file:

> /var/log/vof/vof.err.log

> {

>     daily
>     rotate 4
>     missingok
>     notifempty

> }

The above file enables logrotate to be executed daily and only keep the most recent 4 compressed logs. If there are no logs, compression is not done. A Slack notification is then sent to the specified slack channel.
This has been implemented using the `logrotate_config` function in the start_vof.sh file.
Checkout more information on log rotate [here](https://www.linode.com/docs/uptime/logs/use-logrotate-to-manage-log-files).

### Configuring Slack Notifications
After the above cronjobs have been executed, we need to send slack notifications. This can be done using slack webhooks.
1. From your slack inbox, click on the ```settings``` icon.
2. Click on ```Add an app```.
3. search ```webhook``` and select ```incoming webhook```.
4. From ```Integration settings```, copy the webhook URl
Use this command to setup the channel, username and emoji of the webhook as well as the content of the message and add the webhook url:
``` curl -X POST --data-urlencode "payload={ \"channel\": \"#your-channel\", \"username\": \"webhook-username\", \"text\": \"The message\", \"icon_emoji\": \":slack:\"}" ${var.slack_hook_url}```

After making changes accordingly, run the command and check your slack channel for the notification. In this project, the command is run by a crontab.

## Conclusion

System maintenance is very important since it ensures that the servers are at their optimal performance. In summary, the unattended upgrades will ensure that all system packages are up to date as well as run security patches. Logrotate will rotate logs weekly and compress old logs hence minimize the amount of disk space used as well as the general cost.
