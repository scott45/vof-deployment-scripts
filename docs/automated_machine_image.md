# Image Creation

## Tech Stack
- Packer - version 1.1.3 was used for this project

## Building a base image for VOF

> **Note:**
The instructions below already assume that 
> - This repository has been cloned to your local machine.
> - You have an account on google cloud platform, with the project on which VOF is being deployed to.
> - You have a service account with at least admin capabilities of Compute Image User, Compute Instance Admin and Service Account Actor.

### Step 1
Create a key for the service account, and place it in the shared folder. Rename the file to account.json.

### Step 2
Change directory to the vof_base_image folder.
`cd vof_base_image`

### Step 3
Provide the value for the Project ID on GCP to the environment key `PROJECT_ID`. Ensure that the service account file copied on step 1 is generated from this project and that the project 'ID' not the 'Name' is used.

`export PROJECT_ID=<your-project-id>`

### Step 4
Run the command below to ensure that the packer.json file is valid. The command should give back a message response indicating successful validation.

`packer validate packer.json`

### Step 5
Build the packer image with the following command

`packer build packer.json`