variable "vpc_cidr"{
    type = string
    default = "10.0.0.0/16"
}

variable "region"{
    type = string
    description = "The AWS Region where VPC will be deployed"

    validation {
      condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
      error_message = "Please enter a valid AWS region (e.g., us-east-1, us-west-2, eu-central-1)"
    }
}

variable "number_of_devices_per_subnet"{
    description = "Number of devices to support in each subnet"
    type = Number
    default = 249
}

locals {
    usable_ips = var.number_of_devices_per_subnet + 5 # Add 5 for reserved IPs by AWS

    subnet_mask = (
    local.usable_ips <= 254 ? 24 : # 256 total IPs, 254 usable
    local.usable_ips <= 510 ? 23 : # 512 total IPs, 510 usable
    local.usable_ips <= 1022 ? 22 : 21 # 1024 total IPs, 1022 usable
  )
}