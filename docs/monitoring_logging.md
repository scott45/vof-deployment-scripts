# Monitoring and Logging

## Tech Stack
Stackdriver

## Initial Setup
Gcloud **MUST** be installed in the local computer prior to running this if the logs are to be viewed locally. For this to work, gcloud must be initialized or re-initialized by running the command `gcloud init`.

## Setting Up Monitoring and Logging for VOF using Stackdriver
- Install the Stackdriver gem in the VM instance of the application. Details on this are available on `https://cloud.google.com/error-reporting/docs/setup/ruby`. For this application, the Stackdriver Gem installation is included in the `setup.sh` file which includes all gems that are required to run VOF.
- Use the resulting image in your configuration managemnet tool to build your cloud infrastructure whose instance will log to the logging section of the GCP console.
- 

