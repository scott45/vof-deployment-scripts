# Maintenance


To keep the system on which VOF is running healthy and robust, it is important that some maintenance tasks are carried out. These task aim to keep the host OS;

- Secure by updating packages and getting the latest security patches.
- Ensuring that storage space is conserved by running automated tasks to clean up the system and also keep the system/applications log small. 
- Memory is keep free of log running and memory hungery process by killing them.

## Implementation

- There is a cronjob that is added via a script that runs `unattended_upgrades` on the OS to get the latest packages and security fixes.
- Log rotate package is installed on the system to keep the sizes of the system/application logs in check.