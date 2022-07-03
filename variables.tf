variable "resource_group_name" {
  default       = "rg01"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default       = "eastus"
  description   = "Location of the resource group."
}

variable "virtual_netowrk_name" {
  default       = "vnet-01"
  description   = "Name of the virtual network."
}

variable "storage_account_name" {
  default       = "storage-01"
  description   = "Name of the storage account"
}