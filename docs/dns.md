# DNS


## Steps

1. The project administrator will reserve external global IPs on the google console. The address will be given names based on this format; production-ip, staging-ip, qa-ip and so on. (**required**)
2. This IP will then be manually registered on a DNS service i.e. `vof-devops.andela.com -> 1.1.1.1` (**required**)
3. Each named IP will then be used in the `terraform apply` command as such i.e if production-ip matches the IP 1.1.1.1;

```
terraform apply -var="path=$TF_VAR_state_path" -var="env_name=<production>" -var="vof_disk_image=<vof-packer-image>" -var="reserved_env_ip=1.1.1.1"
```

4. When the command has run to completion, visiting `vof-devops.andela.com` will load the VOF application in the browser. 

## Caution

Reserving a global external static IP address attracts an hourly fee from Google Compute Platform. 