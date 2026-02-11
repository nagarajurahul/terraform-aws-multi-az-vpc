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


variable "number_of_required_ips_per_subnet"{
    description = "Number of required IPs to support in each subnet"
    type = number

    default = 251
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)

  default     = { "Environment" =  "Production" }
}

variable "enable_ipv6" {
  description = "Enable ipv6 for VPC and subnets"
  type = bool

  default = false
}

variable "availability_zones" {
  description = "Availability zones to create public and private subnets"
  type = map(object({
    availability_zone  = string
    public_subnet      = bool
    private_subnet     = bool
    enable_nat_gateway = bool
  }))
  #"For enabling Nat gateway for private subnet in this AZ, we also need to create the public subnet in the same AZ - this is to avoid cross AZ traffic costs"
}
