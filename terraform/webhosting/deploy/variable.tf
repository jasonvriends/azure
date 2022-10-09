# Mandatory

variable "tenant_id" {
   description = "Azure Tenant ID"
   type        = string
   default     = ""
}

variable "subscription_id" {
   description = "Azure Subscription ID"
   type        = string
   default     = ""
}

variable "client_id" {
   description = "Azure Application Registration Application (client) ID"
   type        = string
   default     = ""
}

variable "client_secret" {
   description = "Azure Application Registration client secret"
   type        = string
   default     = ""
}

# Optional

variable "remoteaccess" {
   description = "IP address for remote management"
   type        = string
   default     = "" # defaults to your public IP if not specified
}

variable "region" {
   description = "Azure region for resources"
   type        = string
   default     = "Canada Central"
}

variable "rg_network" {
   description = "Resource group name for Network resources"
   type        = string
   default     = "cyberpanel-rg"
}

variable "rg_vms" {
   description = "Resource group name for Compute resources"
   type        = string
   default     = "cyberpanel-rg"
}

variable "suffix" {
   description = "Suffix to append to resource names"
   type        = string
   default     = "cyberpanel"
}

variable "vm_size" {
   description = "Size of the VM"
   type        = string
   default     = "Standard_B1ms"
}

variable "vm_admin_username" {
   description = "VM admin username"
   type        = string
   default     = "vmadmin"
}

variable "vm_public_key" {
   description = "VM public key path"
   type        = string
   default     = "~/.ssh/id_rsa.pub"
}

