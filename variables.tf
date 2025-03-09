variable "region"{
    type = string
    description = "The AWS Region where VPC will be deployed"

    validation {
      condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
      error_message = "Please enter a valid AWS region (e.g., us-east-1, us-west-2, eu-central-1)"
    }
}

variable "vpc_cidr"{
    type = string
    description = "CIDR block for the VPC"

    default = "10.0.0.0/16"
}

variable "vpc_name"{
    type = string
    description = "Name of the VPC"

    default = "multi-az-vpc"
}


variable "number_of_devices_per_subnet"{
    description = "Number of devices to support in each subnet"
    type = number

    default = 249
}

