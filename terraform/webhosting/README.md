# Web Hosting

This repo contains documentation and Terraform to deploy an Infrastructure as Service web hosting platform for friends and family in Microsoft Azure.

[CyberPanel](https://cyberpanel.net/) is a free web hosting control Panel to deliver speed and security, developed by OpenLiteSpeed and available free of charge to the community.

If your goal exceeds friends and family, I would leverage [CloudLinux](https://www.cloudlinux.com/) + CyberPanel.
- In a normal shared hosting environment the resources available on a server that is the CPU, I/O and RAM resources are fully accessible to all accounts on that server and there is no hard and fast demarcation on the usage of these resources. The clients are expected to share these resources equally. However, sometimes rogue scripts/programs on one clients account to take up disproportionately large amount of resources, thus leading to the server getting overloaded and a general lack of performance, thereby resulting in all the accounts seem slow.
- CloudLinux creates a virtual environment for each individual account on a shared server and allows us to limit the amount of resources any single account can use similar to a VPS environment and therefore no single account can take up every all CPU resources on the server.

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

## CyberPanel Configuration

Login to the Admin cPanel using https://ip-address:8090

### Enable Automatic Security Updates
```
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure  unattended-upgrades
```

### Security

#### ModSecurity

- Select **Security** -> **ModSecurity Conf**
  - Under **ModSecurity**
     - Select **Install Now**

- Select **Security** -> **ModSecurity Conf**
  - Under **ModSecurity**
     - Select **Install Now**

#### CSF

- Select **Security** -> **CSF**
  - Under **CSF**
     - Select **Install Now**

### DNS

#### Create Nameservers in CyberPanel

- Select **DNS** -> **Create Nameserver**
  - Under **Details** specify
    - Domain Name: **yourdomain.com**
    - First Nameserver: **ns1.yourdomain.com**
    - IP Address: **IP of your server**
    - Second Nameserver (Backup): **ns2.yourdomain.com**
    - IP Address: **IP of your server**
    - Select **Create Nameserver**

#### Configure Default Nameservers

- Select **DNS** -> **Config Default Nameservers**
  - Under **Details** specify
    - First Nameserver: **ns1.yourdomain.com**
    - Second Nameserver: **ns2.yourdomain.com**

#### Create Nameservers in your Domain Registar

- Log in to Domain Registars control panel. For GoDaddy:
- Select **Domain**
- Select **Manage DNS**
- Select **...** then Host Names
- Select **Add**
- Input **ns1.yourdomain.com** then the servers **ip address**
- Input **ns2.yourdomain.com** then the servers **ip address**

### Backups

- Select **Backup** -> **Add/Delete Destination**
  - Under **Set up Backup Destinations**
    - Select Type: **Local**
    - Name: **Archive**
    - Local Path: **/archive**
    - Select **Add Destination**

- Select **Backup** -> **Schedule Backup**
  - Under **Create New Backup Schedule**
    - Select Destination: **Archive**
    - Name: **Weekly Full Backup**
    - Select Backup Frequency: **Weekly**
    - Select Backup Retention: **4**
    - Select **Add Schedule**

- Select **Backup** -> **Schedule Backup**
  - Under **Manage Existing Backup Schedules**
    - Select Destination: **Archive**
    - Select Job: Weekly F**ull Backup**
    - Add Sites for Backup: **All**

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