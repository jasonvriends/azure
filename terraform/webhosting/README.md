# Web Hosting

CyberPanel is a free web hosting control Panel to deliver speed and security, developed by OpenLiteSpeed and available free of charge to the community. This repo contains documentation and Terraform to deploy an Infrastructure as Service web hosting platform in Microsoft Azure.

## Requirements

- Microsoft Azure Subscription
- [Hashicorp Terraform](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## CyberPanel Deployment

- Generate SSH key:
  ```
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -C cyberpanel -b 4096 -q -P "<password-to-use-the-key>"
  ```

- Create a clone/copy of an existing repository into a new directory:
  ```
  git clone https://github.com/jasonvriends/azure.git
  ```

- [Authenticate Terraform to Azure using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret)

- Update ```variable.tf``` to your desired values.

- Execute ```terraform plan``` and verify the results.

- Execute ```terraform apply``` if you are satisified with the output of the plan.

- SSH into the Virtual Machine using:
  ```
  SSH username-in-variable.tf@ip-address -i <path_to_private_key>
  ```

- Upgrade to the latest version of CyberPanel using:
  ```
  sudo su - -c "sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh)"
  ```

## CyberPanel Reference

- [Quickstart guide](https://docs.litespeedtech.com/cloud/images/cyberpanel/)

- Admin cPanel: https://ip-address:8090

- User cPanel: https://ip-address:7090

- phpMyAdmin: https://ip-address:8090/dataBases/phpMyAdmin

- Admin password:
  ```
  sudo cat /root/.litespeed_password
  ```

- Mysql user password
  ```
  sudo cat /root/.db_password
  ```

- [Upgrade CyberPanel](https://docs.litespeedtech.com/cloud/cyberpanel/#how-do-i-upgrade-cyberpanel) to the latest version