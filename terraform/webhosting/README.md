# Web Hosting

This repo contains documentation and Terraform to deploy an Infrastructure as Service web hosting platform for friends and family in Microsoft Azure.

## Background

### CyberPanel

[CyberPanel](https://cyberpanel.net/) is a free web hosting control Panel to deliver speed and security, developed by OpenLiteSpeed and available free of charge to the community.

### AlmaLinux

[AlmaLinux](https://almalinux.org/) is an Open Source, community owned and governed, forever-free enterprise Linux distribution, focused on long-term stability, providing a robust production-grade platform. AlmaLinux OS is 1:1 binary compatible with RHEL® and pre-Stream CentOS.

### Shared Hosting

In a normal shared hosting environment the resources available on a server that is the CPU, I/O and RAM resources are fully accessible to all accounts on that server, and there is no hard and fast demarcation on the usage of these resources. The clients are expected to share these resources equally. However, sometimes rogue scripts/programs on one clients account to take up disproportionately large amount of resources, thus leading to the server getting overloaded and a general lack of performance, thereby resulting in all the accounts seem slow.

If you plan to leverage this solution beyond friends and family, I would suggest [CloudLinux](https://www.cloudlinux.com/) + CyberPanel. CloudLinux creates a virtual environment for each individual account on a shared server and allows you to limit the amount of resources any single account can use similar to a VPS environment and therefore no single account can take up every all CPU resources on the server. This brings a lot of benefits to the table for both your clients and you as a host.

## Requirements

- Microsoft Azure Subscription
- RHEL/Rocky/AlmaLinux 8.5 with the following installed:
  - [Git](https://linuxconfig.org/how-to-install-git-on-almalinux)
  - [Hashicorp Terraform](https://www.terraform.io/downloads)

## Azure Deployment

### Overview

The following infrastructure is deployed:
| Name            | Type                   | Location       |
|-----------------|------------------------|----------------|
| cyberpanel-rg   | Resource Group         | Canada Central |
| cyberpanel-vnet | Virtual Network        | Canada Central |
| cyberpanel-vm   | Virtual Machine        | Canada Central |
| cyberpanel-pip  | Public IP address      | Canada Central |
| cyberpanel-os   | Disk                   | Canada Central |
| cyberpanel-nsg  | Network security group | Canada Central |
| cyberpanel-nic  | Network Interface      | Canada Central |

In addition, the Virtual Machine is automatically configured to install security patches daily using dnf-automatic.

### Deployment Steps

An SSH key is an access credential in the SSH protocol. Its function is similar to that of user names and passwords, but the keys are primarily used for automated processes and for implementing single sign-on by system administrators and power users. Execute the following command to create a SSH key.

```
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C cyberpanel -b 4096 -q -P "<password>"
```

Git clone is a way to download a git project from an online repository to your computer. Execute the following command to clone this repoistory to your local computer.

```
git clone https://github.com/jasonvriends/azure.git
```

[Authenticate Terraform to Azure using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret)

Update ```variable.tf``` to your desired values.

Execute ```terraform plan``` and verify the results.

Execute ```terraform apply``` if you are satisified with the output of the plan.

## AlmaLinux Configuraiton

### Secure Shell

SSH into the Virtual Machine using:

```
SSH <username>@<ip-address> -i ~/.ssh/id_rsa
```

### Update Packages:

DNF is a software package manager that installs, updates, and removes packages on AlmaLinux and is the successor to YUM (Yellow-Dog Updater Modified). We can update the existing installed packages using dnf.

**Cloud Init automatically executes the following commands for you. However, the commands are included for your reference.**

```
sudo dnf update -y
```

### Set up Automatic Updates

The dnf-automatic package is a component that allows automatic download and installation of updates. It can automatically monitor and report, via e-mail, the availability of updates or send a log about downloaded packages and installed updates.

**Cloud Init automatically executes the following commands for you. However, the commands are included for your reference.**

```
 # Install the dnf-automatic package
sudo dnf install dnf-automatic -y

# Restrict updates to security
sudo sed -i 's/upgrade_type = default/upgrade_type = security/g' /etc/dnf/automatic.conf

# Apply downloaded updates
sudo sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/dnf/automatic.conf

# Enable the automatic update timer
sudo systemctl enable --now dnf-automatic.timer
```

## CyberPanel Installation

Install CyberPanel using the following command:

```
sudo su - -c "sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)"
```
Choose **1** and **Enter** to **confirm installation**.

Choose **1** and **Enter** to install **CyberPanel with OpenLiteSpeed**.

Choose **Y** and **Enter** to install **Full service for CyberPanel**

Choose **N** and **Enter** to skip remote MySQL setup and continue with local MySQL server setup.

Press **Enter** to continue with latest version of MySQL.

Choose **S** and **Enter** to specify your admin password.

Choose **Y** and **Enter** to install Memcached.

Choose **Y** and **Enter** to install Redis.

Choose **Y** and **Enter** to install WatchDog.

Choose **Y** and **Enter** to restart.

## Cyber Panel Configuration

Login to CyberPanel using https://ip-address:8090

### ModSecurity

ModSecurity (ModSec) is an Apache module that helps protect your website from external attacks. As a web application firewall (WAF), ModSecurity detects and blocks unwanted intrusions into your site.

- Select **Security** -> **ModSecurity Conf**
  - Under **ModSecurity**
     - Select **Install Now**

- Select **Security** -> **ModSecurity Rule Packs**
  - Under **ModSecurity Rules Packages**
     - Enable **OWASP ModSecurity Core Rules**

### ConfigServer Security and Firewall

A Stateful Packet Inspection (SPI) firewall, Login/Intrusion Detection and Security application for Linux servers.

- Select **Security** -> **CSF**
  - Under **CSF**
     - Select **Install Now**

### DNS

Create Nameservers in CyberPanel
- Select **DNS** -> **Create Nameserver**
  - Under **Details** specify
    - Domain Name: **yourdomain.com**
    - First Nameserver: **ns1.yourdomain.com**
    - IP Address: **IP of your server**
    - Second Nameserver (Backup): **ns2.yourdomain.com**
    - IP Address: **IP of your server**
    - Select **Create Nameserver**

Configure Default Nameservers
- Select **DNS** -> **Config Default Nameservers**
  - Under **Details** specify
    - First Nameserver: **ns1.yourdomain.com**
    - Second Nameserver: **ns2.yourdomain.com**

Create Nameservers in your Domain Registar
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
    - Select Job: Weekly **Full Backup**
    - Add Sites for Backup: **All**

## Documentation

- [Quickstart guide](https://docs.litespeedtech.com/cloud/images/cyberpanel/)

- Admin cPanel: https://ip-address:8090

- User cPanel: https://ip-address:7090

- phpMyAdmin: https://ip-address:8090/dataBases/phpMyAdmin

- [Upgrade CyberPanel](https://docs.litespeedtech.com/cloud/cyberpanel/#how-do-i-upgrade-cyberpanel) to the latest version

- [CyberPanel Command Line Interface](https://community.cyberpanel.net/t/cyberpanel-command-line-interface/30683/1)

## Additional Configuration

### SMTP

Outbound email messages that are sent directly to external domains (such as outlook.com and gmail.com) from a virtual machine (VM) are made available only to certain subscription types in Microsoft Azure.

If you would like your friends and family to receive email messages from the server (i.e. WordPress installation information), have a look at [Integrating SendGrid with Postfix](https://docs.sendgrid.com/for-developers/sending-email/postfix).

In addition to the [Integrating SendGrid with Postfix](https://docs.sendgrid.com/for-developers/sending-email/postfix) steps, I had to do the following:

- Define a DNS name on the Azure Public IP address (i.e. ```<dns-name>.canadacentral.cloudapp.azure.com```).
- Modify ```nano /etc/postfix/main.cf``` as per the following: 
  - mydestination = localhost, localhost.localdomain, ```<dns-name>.canadacentral.cloudapp.azure.com```
  - myhostname = ```<dns-name>.canadacentral.cloudapp.azure.com```
  - mynetworks = 127.0.0.0/8, ```<public-ip>/32```, ```<private-ip>/32```

SendGrid Free gives you 100 emails per day.

### MFA

CyberPanel has built-in MFA. You should follow these steps to enable it for your admin user:
- Select **Users** -> **Modify User**
- Check **2FA**
- Scan with the Google/Microsoft Authenticator app

## Troubleshooting

Sometimes after installing CyberPanel you will receive **Invalid Configuration Value** errors when running **sudo dnf update -y**. Refer to [How To Fix Invalid Configuration Value](https://communicode.io/how-to-fix-failovermethod-error-fedora/) to resolve the error.