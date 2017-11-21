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

> *0 9 * * * sudo unattended-upgrade -v | mail -s "Notification: Upgrades successfully run on $(uname -n)" youremail@domain.com.*


 This crontab runs the command `unattended-upgrade  -v` at 0900hrs every day. It sends an email with the    subject “Notification: Upgrades successfully run on $(uname -n)” to    the specified email address. uname-n adds the machine’s name to the    subject.
This has been implemented using the `run_upgrades` function in the start_vof.sh file.
Checkout  more information on crontabs [here](http://www.adminschoice.com/crontab-quick-reference).

### Implementing logrotate
[Logrotate](https://linux.die.net/man/8/logrotate) will rotate logs daily and compress old logs and therefore minimize the amount of disk space used as well as the general cost.
below is a sample /etc/logrotate.conf file:

> /var/log/vof/vof.err.log

> {

>     weekly
>     rotate 4
>     missingok
>     notifempty
>     mail youremail@domain.com

> }

The above file enables logrotate to be executed weekly and only keep the most recent 4 compressed logs. If there are no logs, compression is not done. An email containing the logs is then sent to the specified email.
This has been implemented using the `logrotate_config` function in the start_vof.sh file.
Checkout more information on log rotate [here](https://www.linode.com/docs/uptime/logs/use-logrotate-to-manage-log-files).

### Configuring Mailgun
Google Compute Engine does not allow outbound connections on ports 25, 465, and 587. By default, these outbound SMTP ports are blocked hence we need a third part email service such as SendGrid, Mailgun, and Mailjet. They allow one to set up and send email through their servers. Mailgun email service was used to enable emailing in the VOF project and here is the how:

**step1:** Create a new Mailgun account on Mailgun's [Google partner page](https://www.mailgun.com/google).

**step2:** Get your credentials from Mailgun. They can be found under the domains tab. NB: The Mailgun SMTP hostname is smtp.mailgun.org

**step3:** Follow the guidelines provided [here](https://cloud.google.com/compute/docs/tutorials/sending-mail/using-mailgun) to relay using postfix.

In this project, relaying using postfix has been implemented automatically using the configure_mailgun function in the start_vof.sh file.


## Conclusion

System maintenance is very important since it ensures that the servers are at their optimal performance. In summary, the unattended upgrades will ensure that all system packages are up to date as well as run security patches. Logrotate will rotate logs weekly and compress old logs hence minimize the amount of disk space used as well as the general cost.
