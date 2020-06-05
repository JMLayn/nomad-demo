########################
# AWS Specific Variables
########################

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region for AWS Components"
}

variable "nomad_region" {
  type        = string
  description = "Region of NOMAD server (not AWS Region)"
  default     = "global"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "192.168.100.0/24"
}

variable "prefix" {
  type        = string
  description = "prefix to identify resources"
  default     = "my_demo"
}

variable "instance_type" {
  type        = string
  description = "machine instance type"
  default     = "t3.micro"
}

variable "aws_key" {
  type        = string
  description = "aws security PEM key"
}

variable "owner_tag" {
  type        = string
  description = "infrastructure owner"
}

variable "ttl_tag" {
  type        = number
  description = "infrastructure owner"
  default     = 72
}

variable "ssh_key" {
  type        = string
  description = "private key"
}

# Azure specific Variables
variable "azure_location" {
  type        = string
  description = "location for the Azure image storage (eastus2)"
  default     = "eastus2"
}
variable "nomad_rg" {
  type        = string
  description = "Name for Azure resource group"
  default     = "rj-nomad"
}
variable "nomad_storage" {
  type        = string
  description = "Name for Azure Image Storage Location"
  default     = "rjstorage"
}
