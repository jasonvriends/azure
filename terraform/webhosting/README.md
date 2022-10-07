# Web Hosting

CyberPanel is a free web hosting control Panel to deliver speed and security, developed by OpenLiteSpeed and available free of charge to the community. This repo contains documentation and Terraform to deploy an Infrastructure as Service web hosting platform in Microsoft Azure.

## Requirements

- Microsoft Azure Subscription
- [Hashicorp Terraform](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment Instructions

Clone the repo using:
```
git clone https://github.com/jasonvriends/azure.git
```

[Authenticate Terraform to Azure using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret)

Update ```variable.tf``` to your desired values.

Execute ```terraform plan``` and verify the results.

Execute ```terraform apply``` if you are satisified with the output of the plan.

SSH into the Virtual Machine using:
```
SSH vmadmin@ip-address -i <path_to_private_key>
```

Obtain the Cyber Panel admin credentials using:
```
cat /root/.litespeed_password
```

Login to the Web Admin Panel using ```https://ip-address:8090```
