variable "location" {
  type        = string
  description = "The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created."
  default     = "eastus"
}