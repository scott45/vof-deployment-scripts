# Release Management

### Introduction 
Release management is the process of managing, planning, scheduling and controlling a software build through different stages and environments; including testing and deploying software releases.  As part of the VOF migration to GCP, it's one of the many practices that was implemented. Described below are the ways team keeps the release process on track for upcoming releases.

### CircleCI
It's the tool that has been used on this VOF project migrated to GCP. CircleCI acts as a platform for both Continuous Integration and Continuous Deployment. CircleCI fits well into this flow being the perfect suit to ensure our needs are met. Furthermore, it's the prefered tool that is being used currently by Andela as an Organization. 

### Vof Requirements
Developers should be able to continuously deploy new changes to the application and roll back to old versions as necessary. This should be executed automatically from a Continuous Integration pipeline. 
- Can deploy newest HEAD of master branch to any environment.

- Can rollback to last deployment as needed.

- Packages assets as needed.

- Restarts application and web servers as needed.

- During deployments the application should have zero downtime.

### Solution
Pipeline Steps
- changes are pushed to the VOF git repository.

- Automatically trigger and execute whenever changes are pushed.

- Pipeline pulls the codebase.

- Runs the test.

- Pipeline should deploy the changes automatically to the staging environment.

- Deployment to production is to be triggered manually via the circleCI web interface and deployed automatically by the pipeline.

- Integrated configured alerts should be sent to notify VOF team of any complete deployment.


To ensure the application has zero downtime during deployment, Blue-Green deployment will be used. This is a technique that reduces downtime and risk by running two identical production environments called Blue and Green. At any time, only one of the environments is live, with the live environment serving all production traffic.

To enable easy rollbacks, A build revert will have to be carried out. Successful builds are given a commit, so the previous succesful run build will be re-run and the deployment process of the previous version will be triggered. 

Semantic Versioning which implements automated release version bumping though not initially being used by VOF on heroku is to be an added feature. This will ensure proper tracking os releases.  

### Conclusion
As per the time of the first presentation, The pipeline is halfway done serving the purposes of running the tests and deployment to a single environment (Production).

### Release plan and Release Notes
To be prepared with the final presentation.
